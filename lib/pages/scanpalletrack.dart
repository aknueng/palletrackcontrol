import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:palletrackcontrol/models/md_account.dart';
import 'package:http/http.dart' as http;
import 'package:palletrackcontrol/models/md_lv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanRackPage extends StatefulWidget {
  const ScanRackPage({super.key});

  @override
  State<ScanRackPage> createState() => _ScanRackPageState();
}


class QrCodeValidator extends TextFieldValidator {
  // pass the error text to the super constructor
  QrCodeValidator({String errorText = 'กรุณาใส่หมายเลข QRCODE ให้ถูกต้อง'})
      : super(errorText);
  @override
  bool get ignoreEmptyValues => true;

  @override
  bool isValid(String? value) {
    // return hasMatch(r'^((+|00)?66|0?)?(9[0-9]{8})$', value!);
    return hasMatch(r'^((QR)([0-9]{7})|(QR)([0-9]{8}))$', value!);
  }
}

class _ScanRackPageState extends State<ScanRackPage> {
  final frmKey = GlobalKey<FormState>();
  MAccount? oAccount;
  bool isInit = false;
  FocusNode? focScanNode;
  Color? colrScanQR = Colors.red[100];
  DateFormat formatYMD = DateFormat("yyyyMMdd");
  Future<List<MLVInfo>>? oAryLV;
  
  TextEditingController scanQR = TextEditingController();
  

  @override
  void initState() {
    super.initState();

    getAccount().whenComplete(() {
      if (oAccount!.code == '' || oAccount!.code.isEmpty) {
        Get.offAndToNamed('/login');
      } else {
        focScanNode = FocusNode();
        focScanNode!.requestFocus();
        focScanNode!.addListener(_onFocusChange);        
      }
    });
  }

  @override
  void dispose() {
    scanQR.dispose();
    focScanNode!.dispose();
    focScanNode!.removeListener(_onFocusChange);    

    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      colrScanQR =
          (focScanNode!.hasFocus) ? Colors.yellow[300]! : Colors.red[100]!;      
    });
  }

  Future getAccount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      oAccount = MAccount(
        code: prefs.getString('code') ?? '',
        shortName: prefs.getString('shortName') ?? '',
        fullName: prefs.getString('fullName') ?? '',
        joinDate: DateTime.parse(
            prefs.getString('joinDate') ?? DateTime.now().toString()),
        posit: prefs.getString('posit') ?? '',
        token: prefs.getString('token') ?? '',
        role: prefs.getString('role') ?? '',
        telephone: prefs.getString('telephone') ?? '',
        logInDate: DateTime.parse(
            prefs.getString('logInDate)') ?? DateTime.now().toString()),
      );
    });
  }

  Future<List<MLVInfo>> fetchLVData() async {
    final response = await http.post(
        Uri.parse('https://scm.dci.co.th/hrisapi/api/emp/getlv'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${oAccount!.token}',
        },
        body: jsonEncode(<String, String>{
          'empCode': oAccount!.code,
          'dateStart': formatYMD
              .format(DateTime.now().subtract(const Duration(days: 90))),
          'dateEnd':
              formatYMD.format(DateTime.now().add(const Duration(days: 30)))
        }));

    if (response.statusCode == 200) {
      // on success, parse the JSON in the response body
      final parser = GetScanHistoryParser(response.body);
      // return parser.parseInBackground();
      Future<List<MLVInfo>> data = parser.parseInBackground();
      data.then(
          (value) => value.sort((a, b) => b.cDateYMD.compareTo(a.cDateYMD)));
      return data;
    } else if (response.statusCode == 401) {
      if (context.mounted) {
        // Navigator.pushNamed(context, '/login');
        Get.offAllNamed('/login');
      }
      throw ('failed to load data');
    } else {
      throw ('failed to load data');
    }
  }

  


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ขาด ลา มาสาย (Leave Record)'),
          centerTitle: false,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.surface,
          leading: IconButton(
            icon: const Icon(FontAwesomeIcons.leftLong),
            onPressed: () => Get.offAllNamed('/'),
          ),
        ),
        body: Column(
          children: [
            TextFormField(
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'SCAN A (ด้าน A)'),
                      QrCodeValidator(),
                    ]),
                    controller: scanQR,
                    focusNode: focScanNode,
                    maxLength: 15,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'SCAN A (ด้าน A)',
                        fillColor: colrScanQR,
                        filled: true,
                        counterText: '',
                        prefixIcon: IconButton(
                            onPressed: () async {
                              final qrcode = await Get.toNamed('/qrcode');
                              setState(() {
                                scanQR.text = qrcode;
                              });
                            },
                            icon: const Icon(FontAwesomeIcons.qrcode)),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                scanQR.text = '';
                              });
                            },
                            icon: const Icon(FontAwesomeIcons.x))),
                    onFieldSubmitted: (value) {
                      // focScanBNode!.requestFocus();
                    },
                  ),
            Divider(thickness: 5, color: theme.colorScheme.primary,),
            FutureBuilder<List<MLVInfo>>(
              future: oAryLV,
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data!.isNotEmpty) {
                    return Column(
                      children: <Widget>[
                        Expanded(
                          child: ListView.separated(
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                String lvtype = "", lvStatus = "";
                                Color? lvStatusCorlor;
                                if (snapshot.data![index].type == "ANNU") {
                                  lvtype = 'ลาพักร้อน';
                                } else if (snapshot.data![index].type == "SICK") {
                                  lvtype = 'ลาป่วย';
                                } else if (snapshot.data![index].type == "BUSI") {
                                  lvtype = 'พักร้อน';
                                } else if (snapshot.data![index].type == "ABSE") {
                                  lvtype = 'ขาดงาน';
                                } else if (snapshot.data![index].type == "PERS") {
                                  lvtype = 'ลากิจ';
                                } else if (snapshot.data![index].type == "MONK") {
                                  lvtype = 'ลาบวช';
                                } else if (snapshot.data![index].type == "CARE") {
                                  lvtype = 'ลาคลอด';
                                }

                                if (snapshot.data![index].reqSTATUS == "APPROVE") {
                                  lvStatus = 'อนุมัติ';
                                  lvStatusCorlor = Colors.greenAccent[400]!;
                                } else if (snapshot.data![index].reqSTATUS ==
                                    "REQUEST") {
                                  lvStatus = 'รอ';
                                  lvStatusCorlor = Colors.yellow[400]!;
                                } else if (snapshot.data![index].reqSTATUS ==
                                    "REJECT") {
                                  lvStatus = 'ไม่อนุมัติ';
                                  lvStatusCorlor = Colors.redAccent[700]!;
                                } else if (snapshot.data![index].reqSTATUS ==
                                    "CANCEL") {
                                  lvStatus = 'ยกเลิก';
                                  lvStatusCorlor = Colors.black45;
                                }

                                return ListTile(
                                  title: Row(
                                    children: [
                                      Text('${snapshot.data![index].cDate}  '),
                                      Text(
                                        '$lvtype (${snapshot.data![index].type})',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  subtitle: Row(
                                    children: [
                                      const Text('เวลา: '),
                                      Text(
                                          '${snapshot.data![index].lvFrom}-${snapshot.data![index].lvTo}'),
                                      const Text(', เหตุผล : '),
                                      Expanded(
                                          child:
                                              Text(snapshot.data![index].reason)),
                                    ],
                                  ),
                                  trailing: TextButton(
                                      onPressed: () {
                                        // if (snapshot.data![index].reqSTATUS ==
                                        //     "REQUEST") {
                                        //   // confirm cancel leave
                                        //   showConfirmDialog(context,
                                        //       snapshot.data![index], lvtype);
                                        // }
                                      },
                                      child: Text(
                                        lvStatus,
                                        style: TextStyle(
                                            color: lvStatusCorlor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      )),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return const Divider();
                              },
                              itemCount: snapshot.data!.length),
                        ),
                      ],
                    );
                  } else {
                    return const Text('ไม่พบข้อมูล');
                  }
                } else if (snapshot.hasError) {
                  return Text('err: ${snapshot.error}');
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
        // floatingActionButton: FloatingActionButton(
        //   shape: const CircleBorder(),
        //   backgroundColor: Colors.indigoAccent[700],
        //   onPressed: () {
        //     Get.offAllNamed('/lvreq');
        //   },
        //   child: const Icon(
        //     FontAwesomeIcons.plus,
        //     color: Colors.white,
        //     size: 50,
        //   ),
        // ),
      ),
      onWillPop: () async {
        // Navigator.pushNamed(context, '/');
        Get.offAllNamed('/');
        return false;
      },
    );
  }
  
}

class GetScanHistoryParser {
  // 1. pass the encoded json as a constructor argument
  GetScanHistoryParser(this.encodedJson);
  final String encodedJson;

  // 2. public method that does the parsing in the background
  Future<List<MLVInfo>> parseInBackground() async {
    // create a port
    final p = ReceivePort();
    // spawn the isolate and wait for it to complete
    await Isolate.spawn(_decodeAndParseJson, p.sendPort);
    // get and return the result data
    return await p.first;
  }

  // 3. json parsing
  Future<void> _decodeAndParseJson(SendPort p) async {
    // decode and parse the json
    final jsonData = jsonDecode(encodedJson);
    //final resultsJson = jsonData['results'] as List<dynamic>;
    final resultsJson = jsonData as List<dynamic>;
    final results = resultsJson.map((json) => MLVInfo.fromJson(json)).toList();
    // return the result data via Isolate.exit()
    Isolate.exit(p, results);
  }
}