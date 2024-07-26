import 'dart:convert';
import 'dart:math';

import 'package:fancy_password_field/fancy_password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:sirkl/common/save_pref_keys.dart';
import 'package:sirkl/common/view/dialog/custom_dial.dart';
import 'package:sirkl/config/s_colors.dart';
import 'package:sirkl/controllers/home_controller.dart';
import 'package:sirkl/controllers/navigation_controller.dart';
import 'package:sirkl/controllers/wallet_connect_modal_controller.dart';

WalletConnectModalController get _walletConnectModalController => Get.find<WalletConnectModalController>();
NavigationController get _navigationController => Get.find<NavigationController>();
HomeController get _homeController => Get.find<HomeController>();

final FancyPasswordController _passwordController = FancyPasswordController();
final TextEditingController _passwordTextController = TextEditingController();
final TextEditingController _passwordConfirmationController = TextEditingController();
final TextEditingController _retrievingTextController = TextEditingController();
final TextEditingController _nameBackupTextController = TextEditingController();

var acceptTermOne = false.obs;
var acceptTermTwo = false.obs;
var acceptTermThree = false.obs;
var acceptTermFour = false.obs;
var acceptTermFive = false.obs;
var passwordAreEquals = false.obs;

var wordOneValidate = false.obs;
var wordTwoValidate = false.obs;
var wordThreeValidate = false.obs;
var wordFourValidate = false.obs;

var backupIsLoading = false.obs;
var saveIsLoading = false.obs;

final box = GetStorage();


final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    drive.DriveApi.driveFileScope
  ],
);

Future<GoogleSignInAccount?> signInWithGoogle() async {
  try {
    final account = await _googleSignIn.signIn();
    return account;
  } catch (error) {
    debugPrint(error.toString());
    return null;
  }
}

Future<drive.DriveApi> getDriveApi(GoogleSignInAccount account) async {
  final authHeaders = await account.authHeaders;
  final authenticatedClient = GoogleAuthClient(authHeaders);
  return drive.DriveApi(authenticatedClient);
}

String encryptMnemonic(String mnemonic, String password) {
  final key = encrypt.Key.fromUtf8(password.padRight(32));
  final iv = encrypt.IV.allZerosOfLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  final encrypted = encrypter.encrypt(mnemonic, iv: iv);
  return encrypted.base64;
}

String decryptMnemonic(String encryptedMnemonic, String password) {
  final key = encrypt.Key.fromUtf8(password.padRight(32));
  final iv = encrypt.IV.allZerosOfLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  final decrypted = encrypter.decrypt64(encryptedMnemonic, iv: iv);
  return decrypted;
}

Future<void> saveWalletToDrive(String mnemonic, String name, String password) async {
  backupIsLoading.value = true;
  final account = await signInWithGoogle();
  if (account == null) {
    backupIsLoading.value = false;
    return;
  }

  final driveApi = await getDriveApi(account);

  final encryptedMnemonic = encryptMnemonic(mnemonic, password);

  final media = drive.Media(
    Stream.fromIterable([utf8.encode(encryptedMnemonic)]),
    encryptedMnemonic.length,
    contentType: 'text/plain'
  );

  const folderName = 'SirklWalletBackup';
  String? folderId = await getFolderId(driveApi, folderName);
  folderId ??= await createFolder(driveApi, folderName);

  final driveFile = drive.File()
    ..name = name
    ..parents = [folderId];

  await driveApi.files.create(driveFile, uploadMedia: media);
}

Future<String?> retrieveWalletFromDrive(String password, String id) async {
  saveIsLoading.value = true;
  final account = await signInWithGoogle();
  if (account == null) {
    saveIsLoading.value = false;
    return null;
  }

  final driveApi = await getDriveApi(account);

  const folderName = 'SirklWalletBackup';
  final folderId = await getFolderId(driveApi, folderName);
  if (folderId == null) {
    return null; // Folder not found
  }

  final fileList = await driveApi.files.list(
    q: "'$folderId' in parents",
    spaces: 'drive',
  );

  if (fileList.files == null || fileList.files!.isEmpty) {
    return null; // No backup found
  }

  final media = await driveApi.files.get(
    id,
    downloadOptions: drive.DownloadOptions.fullMedia,
  ) as drive.Media;

  final encryptedMnemonicBytes = await media.stream.toBytes();
  final encryptedMnemonic = utf8.decode(encryptedMnemonicBytes);

  return decryptMnemonic(encryptedMnemonic, password);
}

Future<String?> getFolderId(drive.DriveApi driveApi, String folderName) async {
  final folderList = await driveApi.files.list(
    q: "mimeType = 'application/vnd.google-apps.folder' and name = '$folderName'",
    spaces: 'drive',
  );
  if (folderList.files != null && folderList.files!.isNotEmpty) {
    return folderList.files!.first.id;
  } else {
    return null;
  }
}

Future<String> createFolder(drive.DriveApi driveApi, String folderName) async {
  final folder = drive.File()
    ..name = folderName
    ..mimeType = 'application/vnd.google-apps.folder';

  final folderCreation = await driveApi.files.create(folder);
  return folderCreation.id!;
}

Future<List<drive.File>> listFilesInSirklFolder() async {
  final account = await signInWithGoogle();
  if (account == null) {
    throw Exception('User not signed in');
  }

  final driveApi = await getDriveApi(account);

  const folderName = 'SirklWalletBackup';
  final folderId = await getFolderId(driveApi, folderName);
  if (folderId == null) {
    return []; // Folder not found
  }

  final fileList = await driveApi.files.list(
    q: "'$folderId' in parents",
    spaces: 'drive',
  );
  return fileList.files ?? [];
}

///Save prompts
Future<void> promptChoseBackupMethod(BuildContext context) async =>
  await showDialog(context: context, builder: (context) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
        ? const Color(0xFF102437)
        : Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
    //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    title: const Column(
      children: [
        Text("Save the seed phrase", style: TextStyle(fontFamily: 'Gilroy', fontSize: 24, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
        SizedBox(height: 2,),
        Text("Create a backup of your seed phrase to never lose the access to your wallet", style: TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w500, fontSize: 14), textAlign: TextAlign.center,),
      ],
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () async {
            Get.back();
            await promptBackupManuallyTerms(context);
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: SColors.activeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child:   SizedBox(
            width: double.infinity,
            child: Text(
              "Save manually",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? const Color(0xFF102437)
                    : Colors.white,
                fontSize: 18,
                decoration: TextDecoration.none,
                fontFamily: "Gilroy",
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6,),
        ElevatedButton(
          onPressed: () async {
            Get.back();
            await promptForPassword(context);
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: SColors.activeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child:   SizedBox(
            width: double.infinity,
            child: Text(
              "Save with Google Drive",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? const Color(0xFF102437)
                    : Colors.white,
                fontSize: 18,
                decoration: TextDecoration.none,
                fontFamily: "Gilroy",
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    ),
  ));

//TODO : Test not logged in save
Future<void> promptForPassword(BuildContext context) async => await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? const Color(0xFF102437)
              : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          title: const Column(
            children: [
              Text("Enter password", style: TextStyle(fontFamily: 'Gilroy', fontSize: 24, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
              SizedBox(height: 2,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("A password is required to encrypt your seed phrase on Google Drive", style: TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w500, fontSize: 14), textAlign: TextAlign.center,),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FancyPasswordField(
                autofocus: true,
                controller: _passwordTextController,
                passwordController: _passwordController,
                hasStrengthIndicator: false,
                validationRuleBuilder: (rules, s){
                  return Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 4, right: 4),
                      child: RichText(
                        text: TextSpan(
                            style:  TextStyle(fontFamily: 'Gilroy', color: MediaQuery.of(context).platformBrightness == Brightness.dark
                                ? Colors.white : Colors.black, fontWeight: FontWeight.w500, fontSize: 13),
                            children: [
                              const TextSpan(text: "The password must contain "),
                              TextSpan(text: "8 characters or more", style: TextStyle(color: rules.firstWhere((e) => e.name == 'Min of 8 characters').validate(s) ? SColors.activeColor : Colors.grey)),
                              const TextSpan(text: ", including at least "),
                              TextSpan(text: "one uppercase letter", style: TextStyle(color: rules.firstWhere((e) => e.name == 'Has uppercase letter').validate(s) ? SColors.activeColor : Colors.grey)),
                              const TextSpan(text: ", "),
                              TextSpan(text: "one number", style: TextStyle(color: rules.firstWhere((e) => e.name == 'Has digit').validate(s) ? SColors.activeColor : Colors.grey)),
                              const TextSpan(text: " and "),
                              TextSpan(text: "one symbol.", style: TextStyle(color: rules.firstWhere((e) => e.name == 'Has special character').validate(s) ? SColors.activeColor : Colors.grey)),
                            ]
                        ),
                      )
                  );
                },
                validationRules: {
                  DigitValidationRule(),
                  UppercaseValidationRule(),
                  SpecialCharacterValidationRule(),
                  MinCharactersValidationRule(8),
                },
                onChanged: (value){
                  setState(() {});
                },
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                if(_passwordTextController.text.isNotEmpty && _passwordController.areAllRulesValidated){
                  Get.back();
                  await promptConfirmationPassword(context, _passwordTextController.text);
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: _passwordTextController.text.isNotEmpty && _passwordController.areAllRulesValidated ? SColors.activeColor : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  "Continue",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? const Color(0xFF102437)
                        : Colors.white,
                    fontSize: 18,
                    decoration: TextDecoration.none,
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

          ],
        ),
      );
    },
  ).then((value) {
    _passwordTextController.clear();
  });
Future<void> promptConfirmationPassword(BuildContext context, String password) async => await showDialog(
  context: context,
  builder: (context) {
    return Obx(() => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
            ? const Color(0xFF102437)
            : Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        title: const Column(
          children: [
            Text("Confirm password", style: TextStyle(fontFamily: 'Gilroy', fontSize: 24, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
            SizedBox(height: 2,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text("Check all the boxes and confirm your password", style: TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w500, fontSize: 14), textAlign: TextAlign.center,),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FancyPasswordField(
              autofocus: true,
              controller: _passwordConfirmationController,
              hasStrengthIndicator: false,
              hasValidationRules: false,
              onChanged: (value){
                if(value == password){
                  passwordAreEquals.value = true;
                } else {
                  passwordAreEquals.value = false;
                }
              },
            ),
            const SizedBox(
              height: 16,
            ),
            Material(
              color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 4,
              child: ListTile(
                onTap: (){
                  acceptTermFour.value = !acceptTermFour.value;
                },
                titleAlignment: ListTileTitleAlignment.top,
                minLeadingWidth: 0,
                horizontalTitleGap: 12,
                visualDensity: VisualDensity.compact,
                contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                leading: SizedBox(
                  height: 24,
                  width: 24,
                  child: Transform.scale(
                    scale: 0.8,
                    child: Checkbox(
                      value: acceptTermFour.value,
                      onChanged: (bool? value) {
                        acceptTermFour.value = !acceptTermFour.value;
                      },
                      checkColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white, // Checkmark color
                      activeColor: SColors.activeColor, // Checkbox background color when checked
                      shape: const CircleBorder(),
                    ),
                  ),
                ),
                title: const Text(
                  "SIRKL.io cannot recover my secret phrase encryption password",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Material(
              color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 4,
              child: ListTile(
                onTap: (){
                  acceptTermFive.value = !acceptTermFive.value;
                },
                titleAlignment: ListTileTitleAlignment.top,
                minLeadingWidth: 0,
                horizontalTitleGap: 12,
                visualDensity: VisualDensity.compact,
                contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                leading: SizedBox(
                  height: 24,
                  width: 24,
                  child: Transform.scale(
                    scale: 0.8,
                    child: Checkbox(
                      value: acceptTermFive.value,
                      onChanged: (bool? value) {
                        acceptTermFive.value = !acceptTermFive.value;
                      },
                      checkColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white, // Checkmark color
                      activeColor: SColors.activeColor, // Checkbox background color when checked
                      shape: const CircleBorder(),
                    ),
                  ),
                ),
                title: const Text(
                  "I understand that if I lose or forget this password, I will lose access to my wallet",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w600,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () async {
              if(passwordAreEquals.value && acceptTermFour.value && acceptTermFive.value){
                Get.back();
                await promptCompleteGoogleDriveBackup(context, password);
              }
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: passwordAreEquals.value && acceptTermFour.value && acceptTermFive.value ? SColors.activeColor : Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                "Continue",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? const Color(0xFF102437)
                      : Colors.white,
                  fontSize: 18,
                  decoration: TextDecoration.none,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  },
).then((value) {
  _passwordConfirmationController.clear();
});
Future<void> promptCompleteGoogleDriveBackup(BuildContext context, String password) async => await showDialog(context: context, builder: (context) => StatefulBuilder(
    builder: (context, setState) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
        ? const Color(0xFF102437)
        : Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
    //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    title: const Column(
      children: [
        Text("Name your backup for easy identification", style: TextStyle(fontFamily: 'Gilroy', fontSize: 24, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
        SizedBox(height: 2,),
        Text("Do not delete it from Google Drive, or you may lose your wallet", style: TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w500, fontSize: 14), textAlign: TextAlign.center,),
      ],
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FancyPasswordField(
          autofocus: true,
          controller: _nameBackupTextController,
          hasStrengthIndicator: false,
          hasValidationRules: false,
          hasShowHidePassword: false,
          obscureText: false,
          style: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w500),
          onChanged: (value){
            setState(() {});
          },
        ),
      ],
    ),
    actions: <Widget>[
      Obx(() => backupIsLoading.value ? Center(child: CircularProgressIndicator(color: SColors.activeColor,)) : ElevatedButton(
        onPressed: () async {
          if(_nameBackupTextController.text.isNotEmpty){
            await saveWalletToDrive(box.read(SharedPref.SEED_PHRASE), _nameBackupTextController.text, password);
            Get.back();
            backupIsLoading.value = false;
            box.remove(SharedPref.SEED_PHRASE);
          }
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: _nameBackupTextController.text.isNotEmpty ? SColors.activeColor : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            "Complete Backup",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? const Color(0xFF102437)
                  : Colors.white,
              fontSize: 18,
              decoration: TextDecoration.none,
              fontFamily: "Gilroy",
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      )),

    ],
  ),
));

Future<void> promptBackupManuallyTerms(BuildContext context) async => await showDialog(context: context, builder: (context) => Obx(() => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
        ? const Color(0xFF102437)
        : Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
    //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    title: const Column(
      children: [
        Text("Save the seed phrase", style: TextStyle(fontFamily: 'Gilroy', fontSize: 24, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
        SizedBox(height: 2,),
        Text("Check all the boxes to confirm that you understand the importance of your seed phrase", style: TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w500, fontSize: 14), textAlign: TextAlign.center,),
      ],
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 4,
          child: ListTile(
            onTap: (){
              acceptTermOne.value = !acceptTermOne.value;
            },
          titleAlignment: ListTileTitleAlignment.top,
            minLeadingWidth: 0,
            horizontalTitleGap: 12,
            visualDensity: VisualDensity.compact,
            contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            leading: SizedBox(
              height: 24,
              width: 24,
              child: Transform.scale(
                scale: 0.8,
                child: Checkbox(
                  value: acceptTermOne.value,
                  onChanged: (bool? value) {
                    acceptTermOne.value = !acceptTermOne.value;
                  },
                  checkColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white, // Checkmark color
                  activeColor: SColors.activeColor, // Checkbox background color when checked
                  shape: const CircleBorder(),
                ),
              ),
            ),
            title: const Text(
              "SIRKL.io does not keep a copy of your seed phrase",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 14.0,
                fontWeight: FontWeight.w600
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Material(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 4,
          child: ListTile(
            onTap: (){
              acceptTermTwo.value = !acceptTermTwo.value;
            },
          titleAlignment: ListTileTitleAlignment.top,
            minLeadingWidth: 0,
            horizontalTitleGap: 12,
            visualDensity: VisualDensity.compact,
            contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            leading: SizedBox(
              height: 24,
              width: 24,
              child: Transform.scale(
                scale: 0.8,
                child: Checkbox(
                  value: acceptTermTwo.value,
                  onChanged: (bool? value) {
                    acceptTermTwo.value = !acceptTermTwo.value;
                  },
                  checkColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white, // Checkmark color
                  activeColor: SColors.activeColor, // Checkbox background color when checked
                  shape: const CircleBorder(),
                ),
              ),
            ),
            title: const Text(
              "Saving this document digitally in text format is not recommended (e.g., screenshot, email…)",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Material(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 4,
          child: ListTile(
            onTap: (){
              acceptTermThree.value = !acceptTermThree.value;
            },
            titleAlignment: ListTileTitleAlignment.top,
            minLeadingWidth: 0,
            horizontalTitleGap: 12,
            visualDensity: VisualDensity.compact,
            contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            leading: SizedBox(
              height: 24,
              width: 24,
              child: Transform.scale(
                scale: 0.8,
                child: Checkbox(
                  value: acceptTermThree.value,
                  onChanged: (bool? value) {
                    acceptTermThree.value = !acceptTermThree.value;
                  },
                  checkColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white, // Checkmark color
                  activeColor: SColors.activeColor, // Checkbox background color when checked
                  shape: const CircleBorder(),
                ),
              ),
            ),
            title: const Text(
              "Write down your secret phrase and keep it in a secure offline location",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              ),
            ),
          ),
        )
      ],
    ),
    actions: <Widget>[
      ElevatedButton(
        onPressed: (){
          if(acceptTermOne.value && acceptTermTwo.value && acceptTermThree.value){
            acceptTermOne.value = false;
            acceptTermTwo.value = false;
            acceptTermThree.value = false;
            Get.back();
            promptCopySeedPhrase(context);
          }
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: acceptTermOne.value && acceptTermTwo.value && acceptTermThree.value ? SColors.activeColor : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            "Continue",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? const Color(0xFF102437)
                  : Colors.white,
              fontSize: 18,
              decoration: TextDecoration.none,
              fontFamily: "Gilroy",
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),

    ],
  ))).then((value){
  acceptTermOne.value = false;
  acceptTermTwo.value = false;
  acceptTermThree.value = false;
});
Future<void> promptCopySeedPhrase(BuildContext context) async => await showDialog(context: context, builder: (context) =>
    LayoutBuilder(
        builder: (context, constraints) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
        ? const Color(0xFF102437)
        : Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Column(
      children: [
        Text("Save the seed phrase", style: TextStyle(fontFamily: 'Gilroy', fontSize: 24, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
        SizedBox(height: 2,),
        Text("Never share your secret phrase with anyone, and keep it secure", style: TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w500, fontSize: 14), textAlign: TextAlign.center,),
      ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: constraints.maxHeight * .355, // 70% height
              width: constraints.maxWidth,
              child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3),
                  itemCount: 12,
                  itemBuilder: (context, index){
                    return Card(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white
                        ,child: Center(child: Text("${index + 1}. ${box.read(SharedPref.SEED_PHRASE).toString().trim().split(' ')[index]}",textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w500, fontSize: 14),)));
              }),
            ),
            InkWell(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: box.read(SharedPref.SEED_PHRASE).toString().trim()));
              },
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.copy, color: SColors.activeColor, size: 18,), const SizedBox(width: 2,), Text("Copy to clipboard", style: TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Gilroy', color: SColors.activeColor),)],),
            ),
            const SizedBox(height: 16,)
          ],
        ),
        actions: <Widget>[
      ElevatedButton(
        onPressed: () async{
          Get.back();
          await promptCompleteManualBackup(context);
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: SColors.activeColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            "Continue",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? const Color(0xFF102437)
                  : Colors.white,
              fontSize: 18,
              decoration: TextDecoration.none,
              fontFamily: "Gilroy",
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),

        ],
      ),
    ));
Future<void> promptCompleteManualBackup(BuildContext context) async {
  var words = box.read(SharedPref.SEED_PHRASE).toString().trim().split(' ');
  await showDialog(context: context, builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
            backgroundColor: MediaQuery
                .of(context)
                .platformBrightness == Brightness.dark
                ? const Color(0xFF102437)
                : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
                vertical: 24, horizontal: 24),
            title: const Column(
              children: [
                Text("Seed phrase confirmation", style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontSize: 24,
                    fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
                SizedBox(height: 2,),
                Text(
                  "Please select the correct response from the seed phrases below",
                  style: TextStyle(fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w500,
                      fontSize: 14), textAlign: TextAlign.center,),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildLabeledRadioButtons(context, "Word #1", generateWords(
                        words, mandatoryIndex: 0), (value) {
                      wordOneValidate.value = value == words[0];
                    }),
                    const SizedBox(height: 12,),
                    buildLabeledRadioButtons(
                        context, "Word #4", generateWords(words, mandatoryIndex: 3), (
                        value) {
                          wordTwoValidate.value = value == words[3];
                    }),
                    const SizedBox(height: 12,),
                    buildLabeledRadioButtons(
                        context, "Word #7", generateWords(words, mandatoryIndex: 6), (
                        value) {
                      wordThreeValidate.value = value == words[6];
                    }),
                    const SizedBox(height: 12,),
                    buildLabeledRadioButtons(
                        context, "Word #11", generateWords(words, mandatoryIndex: 10), (
                        value) {
                      wordFourValidate.value = value == words[10];
                    }),
                    const SizedBox(height: 16,)


                  ],
                )
              ],
            ),
            actions: <Widget>[
              Obx(() => ElevatedButton(
                onPressed: () {
                  if (wordOneValidate.value && wordTwoValidate.value && wordThreeValidate.value && wordFourValidate.value) {
                    box.remove(SharedPref.SEED_PHRASE);
                    Get.back();
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: wordOneValidate.value && wordTwoValidate.value && wordThreeValidate.value && wordFourValidate.value ? SColors.activeColor : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    "Complete backup",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MediaQuery
                          .of(context)
                          .platformBrightness == Brightness.dark
                          ? const Color(0xFF102437)
                          : Colors.white,
                      fontSize: 18,
                      decoration: TextDecoration.none,
                      fontFamily: "Gilroy",
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )),

            ],
          )).then((value){
            wordOneValidate.value = false;
            wordTwoValidate.value = false;
            wordThreeValidate.value = false;
            wordFourValidate.value = false;
  });
}

///Retrieve prompts
Future<void> promptChoseRetrieveMethod(BuildContext context) async =>
      await showDialog(context: context, builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
            ? const Color(0xFF102437)
            : Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Column(
          children: [
            Text("Retrieve your wallet", style: TextStyle(fontFamily: 'Gilroy', fontSize: 24, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
            SizedBox(height: 2,),
            Text("Select the method you would like to use to retrieve your wallet", style: TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w500, fontSize: 14), textAlign: TextAlign.center,),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                Get.back();
                await promptRetrieveManually(context);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: SColors.activeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:   SizedBox(
                width: double.infinity,
                child: Text(
                  "Retrieve manually",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? const Color(0xFF102437)
                        : Colors.white,
                    fontSize: 18,
                    decoration: TextDecoration.none,
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6,),
            ElevatedButton(
              onPressed: () async {
                Get.back();
                await promptChoseFileGoogleDrive(context);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: SColors.activeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:   SizedBox(
                width: double.infinity,
                child: Text(
                  "Retrieve with Google Drive",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? const Color(0xFF102437)
                        : Colors.white,
                    fontSize: 18,
                    decoration: TextDecoration.none,
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      )).then((v)  => _navigationController.hideNavBar.value = _homeController.accessToken.value.isNullOrBlank! ? true : false);

//TODO : Handle scenario not connected, change account, no files
Future<void> promptChoseFileGoogleDrive(BuildContext context) async => await showDialog(context: context, builder: (context) => LayoutBuilder(
    builder: (context, constraints) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? const Color(0xFF102437)
          : Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      title: const Column(
        children: [
          Text("Choose a Backup", style: TextStyle(fontFamily: 'Gilroy', fontSize: 24, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
          SizedBox(height: 2,),
          Text("Select a backup file in order to continue", style: TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w500, fontSize: 14), textAlign: TextAlign.center,),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder<List<drive.File>>(
            future: listFilesInSirklFolder(),
            builder: (context, projectSnap){
              if (projectSnap.connectionState == ConnectionState.none &&
                  projectSnap.hasData == false) {
                return Container();
              } else if(projectSnap.connectionState == ConnectionState.waiting){
                return CircularProgressIndicator(color: SColors.activeColor,);
              } else if(projectSnap.connectionState == ConnectionState.done &&
                projectSnap.hasData == false){
                return const Text("No file was found", style: TextStyle(fontSize: 22, fontFamily: 'Gilroy', fontWeight: FontWeight.w600),);
              }
              return SizedBox(
                height: constraints.maxHeight * .355, // 70% height
                width: constraints.maxWidth,
                child: ListView.builder(
                  itemCount: projectSnap.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () async {
                        Get.back();
                        await promptPasswordRetrieveWalletGoogleDrive(context, projectSnap.data![index].id!);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_outline_rounded, size: 18,),
                            const SizedBox(width: 8,),
                            Text( projectSnap.data?[index].name ?? "", style: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w500, fontSize: 16),),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          )
        ],
      ),
    ),
  )).then((v)  => _navigationController.hideNavBar.value = _homeController.accessToken.value.isNullOrBlank! ? true : false);
Future<void> promptPasswordRetrieveWalletGoogleDrive(BuildContext context, String id) async =>  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? const Color(0xFF102437)
              : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          title: const Column(
            children: [
              Text("Enter password", style: TextStyle(fontFamily: 'Gilroy', fontSize: 24, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
              SizedBox(height: 2,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("A password is required to decrypt your seed phrase on Google Drive", style: TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w500, fontSize: 14), textAlign: TextAlign.center,),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FancyPasswordField(
                autofocus: true,
                controller: _passwordTextController,
                hasStrengthIndicator: false,
                hasValidationRules: false,
                onChanged: (value){
                  setState(() {});
                },
              ),
            ],
          ),
          actions: <Widget>[
            Obx(() => saveIsLoading.value ? Center(child: CircularProgressIndicator(color: SColors.activeColor,),) : ElevatedButton(
              onPressed: () async {
                if(_passwordTextController.text.isNotEmpty && context.mounted){
                  await _walletConnectModalController.retrieveWalletFromMnemonic(context, await retrieveWalletFromDrive(_passwordTextController.text, id) ?? "");
                  saveIsLoading.value = false;
                  Get.back();
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: SColors.activeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  "Retrieve",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? const Color(0xFF102437)
                        : Colors.white,
                    fontSize: 18,
                    decoration: TextDecoration.none,
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )),

          ],
        ),
      );
    },
  ).then((value) {
    _passwordTextController.clear();
    _navigationController.hideNavBar.value = _homeController.accessToken.value.isNullOrBlank! ? true : false;
  });

Future<void> promptRetrieveManually(BuildContext context) async => showDialog(context: context, builder: (context) =>
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF102437) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          contentPadding: const EdgeInsets.all(24),
          title: const Column(
            children: [
              Text("Enter your seed phrase", style: TextStyle(fontFamily: 'Gilroy', fontSize: 24, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
              SizedBox(height: 2,),
              Text("Write or paste the words composing your seed phrase and validate", style: TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w500, fontSize: 14), textAlign: TextAlign.center,),
            ],
          ),
          content: Obx(() =>Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: TextField(
                  controller: _retrievingTextController,
                  onChanged: (input) async {
                    setState(() {});
                    _walletConnectModalController.errorTextRetrieving.value = false;
                  },
                  autofocus: true,
                  minLines: 4,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Example: boat moon hat bottle speaker wallet phone monitor cable paper chair sofa",
                    hintStyle: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Gilroy'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Set border radius
                      borderSide: const BorderSide(color: Colors.grey, width: 1), // Set border color and width
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Set border radius
                      borderSide: const BorderSide(color: Colors.grey, width: 1), // Set border color and width
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Set border radius
                      borderSide: const BorderSide(color: Colors.grey, width: 1), // Set border color and width
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Set padding
                  ),
                ),),
              const SizedBox(height: 12,),
              _walletConnectModalController.errorTextRetrieving.value ? const Text("This user doesn't exist or the seed phrase is incorrect, try again.", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Gilroy', color: Colors.red, fontWeight: FontWeight.w600),) : const SizedBox(),
            ],
          )),
          actions: <Widget>[
            Obx(() => saveIsLoading.value ? Center(child: CircularProgressIndicator(color: SColors.activeColor,)) : TextButton(
              onPressed: () async {
                if(_retrievingTextController.text.trim().split(' ').length >= 12){
                  saveIsLoading.value = true;
                  await _walletConnectModalController.retrieveWalletFromMnemonic(context, _retrievingTextController.text);
                  _retrievingTextController.text = "";
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: _retrievingTextController.text.trim().split(' ').length >= 12 ? SColors.activeColor : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  "Retrieve",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF102437) : Colors.white,
                    fontSize: 16,
                    decoration: TextDecoration.none,
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ))
          ],
        ),
      )).then((v)  => _navigationController.hideNavBar.value = _homeController.accessToken.value.isNullOrBlank! ? true : false);

/// Seed Phrase confirmation utils
Widget buildLabeledRadioButtons(
      BuildContext context,
      String label,
      List<String> options,
      ValueChanged<String> onSelected,
      ) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w500, fontSize: 18),
        ),
        const SizedBox(height: 4),
        buildCustomRadioButtons(context, options, onSelected),
      ],
    );

Widget buildCustomRadioButtons(
      BuildContext context,
      List<String> options,
      ValueChanged<String> onSelected,
      ) {
  String? selectedValue;
  return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: options.map((option) {
            bool isSelected = selectedValue == option;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedValue = option;
                  onSelected(selectedValue!);
                });
              },
              child: Card(
                elevation: 4,
                color: isSelected
                    ? SColors.activeColor
                    : (MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? const Color(0xFF113751)
                    : Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child:  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Gilroy',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
}

List<String> generateWords(List<String> words, {required int mandatoryIndex}) {
    if (words.length < 3) {
      throw ArgumentError("The list must contain at least 3 words.");
    }

    List<String> remainingWords = List.from(words)..removeAt(mandatoryIndex);
    List<String> selectedWords = [words[mandatoryIndex]];

    Random random = Random();
    while (selectedWords.length < 3) {
      selectedWords.add(remainingWords.removeAt(random.nextInt(remainingWords.length)));
    }

    selectedWords.shuffle();
    return selectedWords;
  }

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }

  @override
  void close() {
    _client.close();
  }
}