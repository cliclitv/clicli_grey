import 'dart:convert';
import 'dart:math' show max;

import 'package:clicli_grey/api/post.dart';
import 'package:clicli_grey/instance.dart';
import 'package:clicli_grey/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionManager {
  static Future<PackageInfo> getAppVersion() async {
    return await PackageInfo.fromPlatform();
  }

  static int compare(String v1, String v2) {
    if (v1 == v2) return 0;

    List<String> v1Arr = v1.split('.');
    List<String> v2Arr = v2.split('.');
    int i = 0;
    int diff = 0;
    int v1l = v1Arr.length;
    int v2l = v2Arr.length;
    int maxLen = max(v1Arr.length, v2Arr.length);

    if (v1l < maxLen) v1Arr.addAll(List.generate(maxLen - v1l, (i) => '0'));
    if (v2l < maxLen) v2Arr.addAll(List.generate(maxLen - v2l, (i) => '0'));

    while (
        i < maxLen && (diff = int.parse(v1Arr[i]) - int.parse(v2Arr[i])) == 0) {
      ++i;
    }

    if (diff > 0) {
      return 1;
    } else if (diff < 0) {
      return -1;
    } else {
      return 0;
    }
  }

  static Future<int?> checkUpdate() async {
    final appInfo = jsonDecode((await checkAppUpdateApi()).data);
    final localAppInfo = (await getAppVersion());
    final int major = compare(
        appInfo[0]['apkData']['versionName'].toString(), localAppInfo.version);

    if (major > 0 || major < 0) {
      return major;
    } else if (major == 0) {
      return appInfo[0]['apkData']['versionCode'] -
          int.parse(localAppInfo.buildNumber);
    }

    return 0;
  }
}

Future<void> checkAppUpdate() async {
  int? status;

  try {
    status = await VersionManager.checkUpdate();
    if (status! > 0) {
      showDialog(
          barrierDismissible: false,
          context: Instances.currentContext,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: const Text('??????'),
                content: const Text('?????????????????????(??? ??? ???)???'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('??????'),
                    onPressed: () {
                      launch(
                          'https://cdn.jsdelivr.net/gh/cliclitv/app.clicli.me@master/app-release.apk');
                    },
                  ),
                ],
              ),
            );
          });
    } else {
      showSnackBar('??????????????????');
    }
  } catch (e) {
    showErrorSnackBar('??????????????????');
  }
}
