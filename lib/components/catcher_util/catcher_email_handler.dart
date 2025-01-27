/// This package is platform-compatibility fix for catcher.
/// If official support is release, this should be removed.
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as io;
import 'dart:math' show min;
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:catcher/catcher.dart';
import 'package:chaldea/components/analytics.dart';
import 'package:chaldea/platform_interface/platform/platform.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:intl/intl_standalone.dart';
import 'package:logging/logging.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path/path.dart' as p;
import 'package:pool/pool.dart';

import '../config.dart';
import '../constants.dart';
import '../device_app_info.dart';
import '../git_tool.dart';
import '../logger.dart';
import '../utils.dart' show b64;
import 'catcher_config.dart';

export 'page_report_mode_cross.dart';

class EmailAutoHandlerCross extends EmailAutoHandler {
  final Logger _logger = Logger("EmailAutoHandler");

  // send email one-by-one
  final Pool _pool = Pool(1);

  // limit the maximum emails, for some framework error, they will keep raising
  // similar errors with different stacktrace. It's disastrous.
  final int _maxEmailCount = 10;

  /// all attachments will be zipped into one file,
  /// screenshot as extra attachment
  final List<File> attachments;
  final bool screenshot;

  EmailAutoHandlerCross(
    String smtpHost,
    int smtpPort,
    String senderEmail,
    String senderName,
    String senderPassword,
    List<String> recipients, {
    this.screenshot = false,
    bool enableSsl = false,
    bool enableDeviceParameters = true,
    bool enableApplicationParameters = true,
    bool enableStackTrace = true,
    bool enableCustomParameters = true,
    String? emailTitle,
    String? emailHeader,
    this.attachments = const [],
    bool sendHtml = true,
    bool printLogs = false,
  }) : super(smtpHost, smtpPort, senderEmail, senderName, senderPassword,
            recipients,
            enableSsl: enableSsl,
            enableDeviceParameters: enableDeviceParameters,
            enableApplicationParameters: enableApplicationParameters,
            enableStackTrace: enableStackTrace,
            enableCustomParameters: enableCustomParameters,
            emailTitle: emailTitle,
            emailHeader: emailHeader,
            sendHtml: sendHtml,
            printLogs: printLogs);

  @override
  Future<bool> handle(Report error, BuildContext? context) async {
    StreamAttachment? screenshotAttachment;
    if (screenshot) {
      final screenshotBytes = await _captureScreenshot();
      if (screenshotBytes != null) {
        String shotFn = p.join(db.paths.tempDir, 'crash.jpg');
        // just saved
        if (!PlatformU.isWeb) File(shotFn).writeAsBytesSync(screenshotBytes);
        screenshotAttachment = StreamAttachment(
            Stream<List<int>>.value(screenshotBytes), 'image/jpeg',
            fileName: 'crash.jpg');
      }
    }
    return _pool.withResource<bool>(
        () => _sendMail(error, extraAttach: screenshotAttachment));
  }

  /// store html message that has already be sent
  final HashSet<String> _sentReports = HashSet();

  /// the same error may have different StackTrace
  String _getReportShortSummary(Report report) {
    StringBuffer buffer = StringBuffer();
    buffer.writeln(report.error.toString());
    final lines = report.stackTrace.toString().split('\n');
    int index =
        lines.lastIndexWhere((line) => line.contains('package:chaldea'));
    if (lines.isNotEmpty) {
      buffer.writeAll(lines.take(index < 0 ? 3 : min(index + 1, 20)), '\n');
    }
    return buffer.toString();
  }

  Future<bool> _sendMail(Report report, {Attachment? extraAttach}) async {
    try {
      if (!db.hasNetwork) return false;

      if (await _isBlockedError(report)) return false;

      String reportSummary = _getReportShortSummary(report);
      // don't send email repeatedly
      if (_sentReports.contains(reportSummary)) {
        _logger.fine('"${report.error}" has been sent before');
        return true;
      }

      if (_sentReports.length > _maxEmailCount) {
        _logger.warning(
            'Already reach maximum limit($_maxEmailCount) of sent email, skip');
        return false;
      }

      // wait a moment to let other handlers finish, e.g. FileHandler
      await Future.delayed(const Duration(seconds: 1));

      final message = Message()
        ..from = Address(senderEmail, senderName)
        ..recipients.addAll(recipients)
        ..subject = _getEmailTitle(report)
        ..text = setupRawMessageText(report)
        ..attachments = archiveAttachments(attachments, archiveTmpFp);
      if (extraAttach != null) {
        message.attachments.add(extraAttach);
      }
      if (sendHtml) {
        message.html = await _setupHtmlMessageText(report);
      }
      _printLog("Sending email...");
      if (Analyzer.skipReport()) {
        await Future.delayed(const Duration(seconds: 2));
      } else {
        var result = await send(message, _setupSmtpServer());
        _printLog("Email result: $result ");
      }
      _sentReports.add(reportSummary);
      return true;
    } catch (stacktrace, exception) {
      _printLog(stacktrace.toString());
      _printLog(exception.toString());
      return false;
    } finally {
      // var f = File(archiveTmpFp);
      // if (f.existsSync()) f.deleteSync();
    }
  }

  /// List temporary blocked error on gitee wiki
  ///
  /// Fetch from https://gitee.com/chaldea-center/chaldea/wikis/blocked_error?sort_id=4200566
  /// Use [error.startsWith] to check if blocked or not
  /// These blocked errors should be added into [CatcherUtility.isKnownError] in next version
  List<String>? _blockedErrors;

  Future<bool> _isBlockedError(Report report) async {
    if (_blockedErrors == null) {
      final String content = await GitTool.giteeWikiPage('blocked_error');
      _blockedErrors = [];
      content.trim().split('\n\n').forEach((line) {
        line = line.trim().replaceAll('\r', '');
        if (line.isNotEmpty) _blockedErrors!.add(line);
      });
      logger.d('_blockedErrors=${jsonEncode(_blockedErrors)}');
    }

    final error = (report.error ?? report.errorDetails).toString();
    final stackTrace = report.stackTrace.toString();
    bool? shouldIgnore =
        _blockedErrors?.any((e) => error.contains(e) || stackTrace.contains(e));
    if (shouldIgnore == true) {
      logger.e('don\'t send blocked error', report.error, report.stackTrace);
      return true;
    }
    return false;
  }

  String get archiveTmpFp => '${db.paths.tempDir}/.tmp_attach.zip';

  static List<Attachment> archiveAttachments(List<File> files, String tmpFp,
      {bool dumpMemoryUserdata = true}) {
    if (PlatformU.isWeb) return [];
    if (dumpMemoryUserdata) {
      String mfp = p.join(db.paths.tempDir, 'userdata.memory.json');
      File(mfp).writeAsStringSync(jsonEncode(db.userData), flush: true);
      files.add(File(mfp));
    }

    files = files.where((f) => f.existsSync()).toList();
    if (files.isEmpty) return [];

    var encoder = ZipFileEncoder();
    encoder.create(tmpFp);
    for (File file in files) {
      encoder.addFile(io.File(file.path));
    }
    encoder.close();
    return [FileAttachment(io.File(tmpFp), fileName: 'attachment.zip')];
  }

  Future<List<int>?> _captureScreenshot() async {
    Uint8List? shotBinary = await db.runtimeData.screenshotController?.capture(
      pixelRatio:
          MediaQuery.of(kAppKey.currentContext!).devicePixelRatio * 0.75,
      delay: const Duration(milliseconds: 500),
    );
    if (shotBinary == null) return null;
    final img = decodePng(shotBinary);
    if (img == null) return null;
    return encodeJpg(img, quality: 60);
  }

  SmtpServer _setupSmtpServer() {
    return SmtpServer(smtpHost,
        port: smtpPort,
        ssl: enableSsl,
        username: senderEmail,
        password: senderPassword);
  }

  String? _getEmailTitle(Report report) {
    if (emailTitle?.isNotEmpty == true) {
      return emailTitle;
    } else {
      return "Error: ${report.error}";
    }
  }

  Future<String> _setupHtmlMessageText(Report report) async {
    final escape = const HtmlEscape().convert;
    StringBuffer buffer = StringBuffer("");
    if (emailHeader?.isNotEmpty == true) {
      buffer.write(escape(emailHeader!));
      buffer.write("<hr>");
    }
    buffer.write('<style>h3{margin:0.2em 0;}</style>');

    buffer.write("<h3>Summary:</h3>");
    Map<String, dynamic> summary = {
      'app': '${AppInfo.appName} v${AppInfo.fullVersion2}',
      'dataset': db.gameData.version,
      'os': '${PlatformU.operatingSystem} ${PlatformU.operatingSystemVersion}',
      'lang': Language.current.code,
      'locale': await findSystemLocale(),
      'uuid': AppInfo.uuid,
    };
    for (var entry in summary.entries) {
      buffer
          .write("<b>${entry.key}</b>: ${escape(entry.value.toString())}<br>");
    }
    buffer.write('<hr>');

    buffer.write("<h3>Error:</h3>");
    buffer.write(escape(report.error.toString()));
    if (report.error.toString().trim().isEmpty && report.errorDetails != null) {
      buffer.write(escape(report.errorDetails!.exceptionAsString()));
    }
    buffer.write("<hr>");

    if (enableStackTrace) {
      buffer.write("<h3>Stack trace:</h3>");
      buffer
          .write(escape(report.stackTrace.toString()).replaceAll("\n", "<br>"));
      if (report.stackTrace?.toString().trim().isNotEmpty != true &&
          report.errorDetails != null) {
        buffer.write(escape(report.errorDetails!.stack.toString())
            .replaceAll('\n', '<br>'));
      }
      buffer.write("<hr>");
    }

    if (enableDeviceParameters) {
      buffer.write("<h3>Device parameters:</h3>");
      for (var entry in report.deviceParameters.entries) {
        buffer.write(
            "<b>${entry.key}</b>: ${escape(entry.value.toString())}<br>");
      }
      buffer.write("<hr>");
    }
    if (enableApplicationParameters) {
      buffer.write("<h3>Application parameters:</h3>");
      for (var entry in report.applicationParameters.entries) {
        buffer.write(
            "<b>${entry.key}</b>: ${escape(entry.value.toString())}<br>");
      }
      buffer.write("<hr>");
    }

    if (enableCustomParameters) {
      buffer.write("<h3>Custom parameters:</h3>");
      for (var entry in report.customParameters.entries) {
        buffer.write(
            "<b>${entry.key}</b>: ${escape(entry.value.toString())}<br>");
      }
      buffer.write("<hr>");
    }

    return buffer.toString();
  }

  void _printLog(String log) {
    if (printLogs) {
      _logger.info(log);
    }
  }
}

EmailAutoHandlerCross kEmailAutoHandlerCross(
        {List<File> attachments = const []}) =>
    EmailAutoHandlerCross(
      'smtp.qiye.aliyun.com',
      465,
      'chaldea-client@narumi.cc',
      'Chaldea ${AppInfo.version} Crash',
      b64('Q2hhbGRlYUBjbGllbnQ='),
      [kSupportTeamEmailAddress],
      attachments: attachments,
      screenshot: true,
      enableSsl: true,
      printLogs: true,
    );
