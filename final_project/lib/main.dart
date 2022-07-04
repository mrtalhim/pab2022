import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:sklite/naivebayes/naive_bayes.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:sklite/utils/io.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prediksi Level Asesmen PPKM',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Prediksi Level Asesmen PPKM'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PPKMForm(),
    );
  }
}

class PPKMForm extends StatefulWidget {
  const PPKMForm({Key? key}) : super(key: key);

  @override
  _PPKMFormState createState() {
    return _PPKMFormState();
  }
}

class _PPKMFormState extends State<PPKMForm> {
  late GaussianNB gnb;
  late Map<String, dynamic> y;
  List<double> input = List.filled(8, 0);
  List inputVar = [
    'Kasus Konfirmasi per 100.000 penduduk/ minggu',
    'Rawat Inap RS per 100.000 penduduk/ minggu',
    'Meninggal per 100.000 penduduk/ minggu',
    'Positivity Rate (%) (7 hari terakhir)',
    'Tracing (Rasio Kontak Erat/Kasus Konfirmasi/ Minggu)',
    'Treatment (BOR/minggu)',
    'Cakupan Vaksinasi Lengkap (%)',
    'Cakupan Vaksinasi Lengkap Lansia (%)'
  ];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int output = 0;

  @override
  void initState() {
    super.initState();
    loadModel("assets/gnb.json").then(
      (x) => {
        y = Map.from(json.decode(x)),
        gnb = GaussianNB(
          List<double>.from(y['class_prior_']),
          List<List<dynamic>>.from(y['sigma_']),
          List<List<dynamic>>.from(y['theta_']),
          [1, 2, 3], // class
        )
      },
    );
    print('model loaded');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...List.generate(
                inputVar.length,
                (index) => TextFormField(
                    decoration: InputDecoration(
                      hintText: inputVar[index],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'required';
                      }

                      input[index] = double.parse(value);

                      return null;
                    })),
            ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;

                output = gnb.predict(input);
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                        content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('PPKM Level'),
                        Text(output.toString()),
                      ],
                    ));
                  },
                );
              },
              child: Text('Hitung'),
            ),
          ],
        ),
      ),
    );
  }
}
