import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ModelRocket(),
    );
  }
}

class ModelRocket extends StatefulWidget {
  @override
  State<ModelRocket> createState() => _ModelRocketState();
}

class _ModelRocketState extends State<ModelRocket> {
  late Scene _scene;
  Object? _cube;
  //
  String veri = "";
  String ax = "";
  String ay = "";
  String az = "";
  double pitch = 0;
  double roll = 0;
  double yaw = 0;
  List<String> parserData = [];
  List<double> doubleAngle = [];
  List<String> availablePort = SerialPort.availablePorts;
  Widget? nesne;
  void sahne(Scene scene) {
    _scene = scene;
    _cube = Object(
      fileName: "lib/ModelObject/roket/12217_rocket_v1_l1.obj",
      rotation: Vector3(pitch, roll, yaw),
      lighting: true,
      backfaceCulling: false,
    );
    scene.world.add(_cube!);
    scene.camera.zoom = 8;
  }

  Future<void> loraVeriPaketi() async {
    try {
      SerialPort port1 = SerialPort('COM7'); // com7 portuna baglan.
      port1.openReadWrite(); // port uzerinden okuma ve yazmayi ac.
      // okuma - receiver kodu :
      final reader2 = SerialPortReader(port1);
      reader2.stream.listen((data) async {
        // uint8 list to string veri paketi dönüştürücü
        String convertUint8ListToString(Uint8List uint8list) {
          return String.fromCharCodes(uint8list);
        }

        veri = await convertUint8ListToString(data);
        setState(() {
          parserData = veri.split('/');
          ax = parserData[0];
          ay = parserData[1];
          az = parserData[2];
          //
          pitch = double.parse(ax);
          roll = double.parse(ay);
          yaw = double.parse(az);
        });
        //
        _cube!.rotation.x = pitch;
        _cube!.rotation.y = roll;
        _cube!.rotation.z = yaw;
        _cube!.updateTransform();
        _scene.update();
        print(veri);
      });
    } on SerialPortError catch (err, _) {
      //print(SerialPort.lastError); // baglanti hatasini dondur.
    }
  }

  @override
  void initState() {
    super.initState();
    loraVeriPaketi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          children: [
            Align(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Pitch : $ax"),
                  Text("Roll : $ay"),
                  Text("Yaw : $az"),
                ],
              ),
            ),
            Container(
              child: Cube(
                onSceneCreated: sahne,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
