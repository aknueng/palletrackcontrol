import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:palletrackcontrol/models/md_account.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class PalletNoValidator extends TextFieldValidator {
  // pass the error text to the super constructor
  PalletNoValidator({String errorText = 'กรุณาใส่หมายเลข Pallet ถูกต้อง'})
      : super(errorText);
  @override
  bool get ignoreEmptyValues => true;

  @override
  bool isValid(String? value) {
    // return hasMatch(r'^((+|00)?66|0?)?(9[0-9]{8})$', value!);
    return hasMatch(r'[0-9]{5}$', value!);
  }
}

class QrCodeAValidator extends TextFieldValidator {
  // pass the error text to the super constructor
  QrCodeAValidator({String errorText = 'กรุณาใส่หมายเลข Pallet ถูกต้อง'})
      : super(errorText);
  @override
  bool get ignoreEmptyValues => true;

  @override
  bool isValid(String? value) {
    // return hasMatch(r'^((+|00)?66|0?)?(9[0-9]{8})$', value!);
    return hasMatch(r'^((QR)([0-9]{7})|(QR)([0-9]{8}))$', value!);
  }
}

class QrCodeBValidator extends TextFieldValidator {
  // pass the error text to the super constructor
  QrCodeBValidator({String errorText = 'กรุณาใส่หมายเลข Pallet ถูกต้อง'})
      : super(errorText);
  @override
  bool get ignoreEmptyValues => true;

  @override
  bool isValid(String? value) {
    // return hasMatch(r'^((+|00)?66|0?)?(9[0-9]{8})$', value!);
    return hasMatch(r'^((QR)([0-9]{7})|(QR)([0-9]{8}))$', value!);
  }
}

class _RegisterPageState extends State<RegisterPage> {
  final frmKeyStep0 = GlobalKey<FormState>();
  final frmKeyStep1 = GlobalKey<FormState>();
  final frmKeyStep2 = GlobalKey<FormState>();
  MAccount? oAccount;
  bool isInit = false;
  FocusNode? focScanANode;
  FocusNode? focScanBNode;
  FocusNode? focRackNoNode;
  FocusNode? focRackTypeNode;
  Color? colrScanA = Colors.red[100];
  Color? colrScanB = Colors.red[100];
  Color? colrRackNo = Colors.red[100];
  // we have initialized active step to 0 so that
  // our stepper widget will start from first step
  int _activeCurrentStep = 0;

  TextEditingController scanA = TextEditingController();
  TextEditingController scanB = TextEditingController();
  TextEditingController rackNo = TextEditingController();
  TextEditingController rackType = TextEditingController();

  bool compareQrCode(String compareA, String compareB) {
    if ((compareA == '' || compareA.isEmpty) ||
        (compareB == '' || compareB.isEmpty)) {
      return false;
    } else if (compareA == compareB) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();

    getAccount().whenComplete(() {
      if (oAccount!.code == '' || oAccount!.code.isEmpty) {
        Get.offAndToNamed('/login');
      } else {
        focScanANode = FocusNode();
        focScanANode!.requestFocus();
        focScanANode!.addListener(_onFocusChange);

        focScanBNode = FocusNode();
        focScanBNode!.requestFocus();
        focScanBNode!.addListener(_onFocusChange);

        focRackNoNode = FocusNode();
        focRackNoNode!.requestFocus();
        focRackNoNode!.addListener(_onFocusChange);

        focRackTypeNode = FocusNode();
        focRackTypeNode!.requestFocus();
        focRackTypeNode!.addListener(_onFocusChange);
      }
    });
  }

  @override
  void dispose() {
    scanA.dispose();
    scanB.dispose();
    rackNo.dispose();
    rackType.dispose();
    focScanANode!.dispose();
    focScanANode!.removeListener(_onFocusChange);
    focScanBNode!.dispose();
    focScanBNode!.removeListener(_onFocusChange);
    focRackNoNode!.dispose();
    focRackNoNode!.removeListener(_onFocusChange);
    focRackTypeNode!.dispose();
    focRackTypeNode!.removeListener(_onFocusChange);

    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      colrScanA =
          (focScanANode!.hasFocus) ? Colors.yellow[300]! : Colors.red[100]!;
      colrScanB =
          (focScanBNode!.hasFocus) ? Colors.yellow[300]! : Colors.red[100]!;
      colrRackNo =
          (focRackNoNode!.hasFocus) ? Colors.yellow[300]! : Colors.red[100]!;
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

  // Here we have created list of steps
  // that are required to complete the form
  List<Step> stepList() => [
        // This is step1 which is called Account.
        // Here we will fill our personal details
        Step(
          state:
              _activeCurrentStep <= 0 ? StepState.editing : StepState.complete,
          isActive: _activeCurrentStep >= 0,
          title: const Text('QRCODE'),
          content: Expanded(
            child: Form(
              key: frmKeyStep0,
              child: Column(
                children: [
                  TextFormField(
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'SCAN A (ด้าน A)'),
                      QrCodeAValidator(),
                    ]),
                    controller: scanA,
                    focusNode: focScanANode,
                    maxLength: 15,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'SCAN A (ด้าน A)',
                        fillColor: colrScanA,
                        filled: true,
                        counterText: '',
                        prefixIcon: IconButton(
                            onPressed: () async {
                              final qrcode = await Get.toNamed('/qrcode');
                              setState(() {
                                scanA.text = qrcode;
                              });
                            },
                            icon: const Icon(FontAwesomeIcons.qrcode)),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                scanA.text = '';
                              });
                            },
                            icon: const Icon(FontAwesomeIcons.x))),
                    onFieldSubmitted: (value) {
                      focScanBNode!.requestFocus();
                    },
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'SCAN B (ด้าน B)'),
                      QrCodeBValidator(),
                    ]),
                    controller: scanB,
                    focusNode: focScanBNode,
                    maxLength: 15,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'SCAN B (ด้าน B)',
                      fillColor: colrScanB,
                      filled: true,
                      counterText: '',
                      prefixIcon: IconButton(
                          onPressed: () async {
                            final qrcode = await Get.toNamed('/qrcode');
                            setState(() {
                              scanB.text = qrcode;
                            });
                          },
                          icon: const Icon(FontAwesomeIcons.qrcode)),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              scanB.text = '';
                            });
                          },
                          icon: const Icon(FontAwesomeIcons.x)),
                    ),
                    onFieldSubmitted: (value) {
                      //focRackTypeNode!.requestFocus();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        // This is Step2 here we will enter our address
        Step(
            state: _activeCurrentStep <= 1
                ? StepState.editing
                : StepState.complete,
            isActive: _activeCurrentStep >= 1,
            title: const Text('PL TYPE'),
            content: Expanded(
              child: Form(
                key: frmKeyStep1,
                child: Column(
                  children: [
                    Text(scanA.text),
                    const SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      controller: rackType,
                      focusNode: focRackTypeNode,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Rack Type',
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      validator: MultiValidator([
                        RequiredValidator(errorText: 'กรุณาเลข Pallet'),
                        MinLengthValidator(5,
                            errorText: 'กรุณาเลข Pallet 5 ตัวอักษร'),
                        PalletNoValidator(),
                      ]),
                      controller: rackNo,
                      focusNode: focRackNoNode,
                      maxLength: 5,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'เลขที่ Pallet',
                        fillColor: colrRackNo,
                        filled: true,
                        counterText: '',
                      ),
                      onFieldSubmitted: (value) {
                        focRackTypeNode!.requestFocus();
                      },
                    ),
                  ],
                ),
              ),
            )),

        // This is Step3 here we will display all the details
        // that are entered by the user
        Step(
            state: StepState.complete,
            isActive: _activeCurrentStep >= 2,
            title: const Text('CONFIRM'),
            content: Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('rackType: ${rackType.text}'),
                Text('rackNO: ${rackNo.text}'),
                Text('QrCode: ${scanA.text}'),
                // Text('Address : ${address.text}'),
                // Text('PinCode : ${pincode.text}'),
              ],
            )))
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.surface,
        title: const Text(
          'ลงทะเบียน Pallet Rack',
          // style: TextStyle(color: Colors.white),
        ),
      ),
      // Here we have initialized the stepper widget
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _activeCurrentStep,
        steps: stepList(),

        // onStepContinue takes us to the next step
        onStepContinue: () {
          if (_activeCurrentStep < (stepList().length - 1)) {
            if (_activeCurrentStep == 0) {
              if (frmKeyStep0.currentState!.validate()) {
                if (compareQrCode(scanA.text, scanB.text)) {
                  frmKeyStep0.currentState!.save();

                  // await checkLogin();
                  setState(() {
                    _activeCurrentStep += 1;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content:
                        Text('SCAN B (ด้าน B) และ SCAN B (ด้าน B) ไม่ตรงกัน'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.fromLTRB(50, 0, 50, 50),
                  ));
                }
              }
            } else if (_activeCurrentStep == 1) {
              if (frmKeyStep1.currentState!.validate()) {
                setState(() {
                  _activeCurrentStep += 1;
                });
              }
            } else if (_activeCurrentStep == 2) {}
          }

          // debugPrint(' ++++++++++   $_activeCurrentStep   ++++++++++');
        },

        // onStepCancel takes us to the previous step
        onStepCancel: () {
          if (_activeCurrentStep == 0) {
            return;
          }

          setState(() {
            _activeCurrentStep -= 1;
          });

          // debugPrint(' -----------   $_activeCurrentStep   -----------');
        },

        // onStepTap allows to directly click on the particular step we want
        onStepTapped: (int index) {
          setState(() {
            //_activeCurrentStep = index;
          });
        },
      ),
    );
  }
}
