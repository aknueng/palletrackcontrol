import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:palletrackcontrol/models/md_account.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool obSecurePass = true;
  String userName = '';
  String passWord = '';
  final formKey = GlobalKey<FormState>();
  late Future<MAccount> oAccount;

  @override
  void initState() {
    super.initState();

    oAccount = fetchDataLogin();
  }

  void toggle() {
    setState(() {
      obSecurePass = !obSecurePass;
    });
  }

  Future checkLogin() async {
    setState(() {
      oAccount = fetchDataLogin();

      oAccount.then(
        (res) async {
          final SharedPreferences prefs = await SharedPreferences.getInstance();

          if (res.code != '' && res.code.isNotEmpty) {
            prefs.setString('code', res.code);
            prefs.setString('shortName', res.shortName);
            prefs.setString('fullName', res.fullName);
            prefs.setString('joinDate', res.joinDate.toString());
            prefs.setString('posit', res.posit);
            prefs.setString('token', res.token);
            prefs.setString('role', res.role);
            prefs.setString('telephone', res.telephone);
            prefs.setString('logInDate', res.logInDate.toString());

            Get.offAllNamed('/scan');
          } else {
            if (context.mounted) {
              formKey.currentState!.validate();

              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('user & password faild'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.fromLTRB(50, 0, 50, 50),
              ));
            }
          }
        },
      );
    });
  }

  Future<MAccount> fetchDataLogin() async {
    final response = await http.post(
        Uri.parse('https://scm.dci.co.th/hrisapi/api/Authen'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'user': userName, 'pass': passWord}));

    if (response.statusCode.toString().startsWith("2")) {
      return MAccount.fromJson(jsonDecode(response.body));
    } else if (response.statusCode.toString().startsWith("4")) {
      return MAccount(
          code: '',
          shortName: '',
          fullName: '',
          joinDate: DateTime.now(),
          posit: '',
          token: '',
          role: '',
          telephone: '',
          logInDate: DateTime.now());
    } else {
      throw Exception('fail login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PALLET RACK CONTROL'),
          centerTitle: true,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.surface,
        ),
        body: Form(
          key: formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                const Image(
                  image: AssetImage('assets/images/dci_logo.png'),
                  width: 270,
                ),
                Container(
                    alignment: Alignment.topCenter,
                    child: Wrap(children: [
                      Text(
                        '  PALLET RACK\r\n      CONTROL',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0, // shadow blur
                              color: Colors.grey[500]!, // shadow color
                              offset: const Offset(
                                  2.0, 2.0), // how much shadow will be shown
                            ),
                          ],
                        ),
                      ),
                    ])),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10, left: 50, right: 50),
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        color: Colors.black38.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 0)
                  ]),
                  child: TextFormField(
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'กรุณากรอกรหัสพนักงาน'),
                      MinLengthValidator(5, errorText: 'รหัสพนักงาน 5 ตัวอักษร')
                    ]),
                    onSaved: (usr) {
                      userName = usr.toString();
                    },
                    autofillHints: const [AutofillHints.username],
                    maxLength: 5,
                    decoration: InputDecoration(
                      hintText: 'รหัสพนักงาน',
                      labelText: 'รหัสพนักงาน',
                      fillColor: Colors.lime[50],
                      filled: true,
                      counterText: '',
                      contentPadding: const EdgeInsets.all(10),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(FontAwesomeIcons.user),
                      ),
                      suffixIcon: const Padding(
                        padding: EdgeInsets.only(left: 0, right: 25),
                        child: Icon(
                          FontAwesomeIcons.starOfLife,
                          size: 10,
                        ),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              const BorderSide(color: Colors.orangeAccent)),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10, left: 50, right: 50),
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        color: Colors.black38.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 0)
                  ]),
                  child: TextFormField(
                      validator: MultiValidator([
                        RequiredValidator(errorText: 'กรุณากรอกรหัสผ่าน'),
                        MinLengthValidator(6,
                            errorText: 'กรุณากรอกรหัสผ่าน 6 ตัวอักษรขึ้นไป')
                      ]),
                      onSaved: (pwd) {
                        passWord = pwd.toString();
                      },
                      autofillHints: const [AutofillHints.password],
                      maxLength: 20,
                      obscureText: obSecurePass,
                      decoration: InputDecoration(
                          hintText: 'รหัสผ่าน',
                          labelText: 'รหัสผ่าน',
                          fillColor: Colors.lime[50],
                          filled: true,
                          counterText: '',
                          contentPadding: const EdgeInsets.all(10),
                          prefixIcon: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(FontAwesomeIcons.key)),
                          suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: IconButton(
                                  onPressed: () {
                                    toggle();
                                  },
                                  icon: (obSecurePass)
                                      ? const Icon(
                                          FontAwesomeIcons.starOfLife,
                                          size: 10,
                                        )
                                      : const Icon(
                                          FontAwesomeIcons.eye,
                                          size: 10,
                                        ))),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                  color: Colors.orangeAccent)))),
                ),
                // Container(
                //     alignment: Alignment.centerLeft,
                //     margin: const EdgeInsets.only(
                //       left: 40,
                //     ),
                //     child: TextButton(
                //         onPressed: () {},
                //         child: const Text(
                //           'ลืมรหัสผ่าน?',
                //           style:
                //               TextStyle(decoration: TextDecoration.underline),
                //         ))),
                const SizedBox(
                  height: 50,
                ),
                FutureBuilder<MAccount>(
                    future: oAccount,
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.connectionState == ConnectionState.done &&
                          snapshot.data!.code != '') {
                        //return Text(' log in - ${snapshot.data!.code} ${snapshot.data!.fullName}');
                        return const Text('');
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else {
                        return SizedBox(
                          width: 200,
                          height: 40,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                TextInput.finishAutofillContext();

                                formKey.currentState!.save();
                                await checkLogin();
                              }
                              //formKey.currentState!.reset();
                            },
                            label: const Text('     เข้าสู่ระบบ'),
                            icon: const Icon(FontAwesomeIcons.userLock),
                          ),
                        );
                      }
                    }),
              ],
            ),
          ),
        ),
        // bottomNavigationBar: Container(
        //     alignment: Alignment.bottomCenter,
        //     child: const Text('Create by AKONE')),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }
}
