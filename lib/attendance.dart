import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class HroneAttendance extends StatefulWidget {
  const HroneAttendance({Key? key}) : super(key: key);

  @override
  State<HroneAttendance> createState() => _HroneAttendanceState();
}

class _HroneAttendanceState extends State<HroneAttendance> {
  String? _currentAddress;
  Position? _currentPosition;
  String? base64Image;
  final ImagePicker _picker = ImagePicker();
  XFile? image;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    _getCurrentPosition();
    super.initState();
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
        _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
        '${place.street}, ${place.subLocality},${place
            .subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  String convertDateTimeFormat(DateTime dateTime) {
    final dateTimeConverted = DateFormat("dd-mm-yyyy hh:mm").format(dateTime);
    return dateTimeConverted;
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white.withOpacity(0.9),
        appBar: AppBar(
          title: const Text("Mark Attendance"),
        ),
        body: SingleChildScrollView(
            child: Container(
                alignment: Alignment.center,
                height: MediaQuery
                    .sizeOf(context)
                    .height,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        width: MediaQuery
                            .sizeOf(context)
                            .width * 0.9,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 16,
                            ),
                            const Text(
                              "CLICK A PICTURE",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Container(
                               margin: const EdgeInsets.only(bottom:12.0),
                              padding: const EdgeInsets.all(12.0),
                              width:MediaQuery.sizeOf(context).width,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              child:InkWell(
                                onTap: () async {
                                  image = await _picker.pickImage(
                                      source: ImageSource.gallery);
                                  setState(() {});
                                },
                                child: image != null
                                    ? Image.file(
                                  File(image!.path),
                                  width: 100,
                                  fit: BoxFit.cover,
                                )
                                    : const Icon(Icons.image,
                                  size: 100,
                                ),
                              ),),
                            const Text(
                              "CURRENT LOCATION",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            const Text("Address",
                                style: TextStyle(color: Colors.grey)),
                            Text(_currentAddress ?? "Location not found!",
                                style: const TextStyle()),
                            const SizedBox(
                              height: 16,
                            ),
                            const Text("Coordinates",
                                style: TextStyle(color: Colors.grey)),
                            Text(
                                "${_currentPosition?.latitude ??
                                    ""} ${_currentPosition?.longitude ?? ""} ",
                                style: const TextStyle()),
                            const SizedBox(
                              height: 16,
                            ),
                            const Text("Punch Time",
                                style: TextStyle(color: Colors.grey)),
                            Text(convertDateTimeFormat(DateTime.now()),
                                style: const TextStyle()),
                            const SizedBox(
                              height: 16,
                            ),
                          ],
                        )),
                    const SizedBox(height: 40),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(12),
                        width: MediaQuery
                            .sizeOf(context)
                            .width * 0.9,
                        child: Column(
                           // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [const Text("*Comments"),
                              TextField(
                                controller: controller,
                                keyboardType: TextInputType.text,
                              )
                            ])),
                    const SizedBox(height: 40),
                    // base64Image!=null?Image.memory(base64Decode(base64Image!)):SizedBox(),
                    _currentAddress != null&&
                        //controller.text!=""&&
                        _currentPosition?.latitude!=null&&image?.path!=null? MaterialButton(
                      onPressed: () {
                        generatecsv();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Attendance marked successfully!")));
                        Navigator.pop(context);
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      height: 60,
                      color:  Colors.green,
                      minWidth: MediaQuery
                          .sizeOf(context)
                          .width * 0.8,
                      child: const Text("Submit Request"),
                    ):const SizedBox()
                  ],
                ))));
  }

  generatecsv() async {
    final bytes = File(image!.path).readAsBytesSync();
    setState(() {
       base64Image =  base64Encode(bytes);
    });
    print("img_pan : $base64Image");
    final String directory = (await getApplicationSupportDirectory()).path;
    final path = "$directory/csv-hrone1.csv";
    List<List<String>>? data;
    if(await File(path).exists()){
      setState(() {
       data = [
        [
          "\r\n${_currentPosition!.latitude}${_currentPosition!.longitude}",
          _currentAddress!,
          convertDateTimeFormat(DateTime.now()),_currentAddress!,base64Image!,
        ]
      ];

      });
    }
    else {
      setState(() {
        data = [
          ["Coordinates", "Current Address", "Current Datetime","Current Picture"],
          [
            _currentPosition!.latitude.toString() +
                _currentPosition!.longitude.toString(),
            convertDateTimeFormat(DateTime.now()),_currentAddress!,base64Image!,
          ]
        ];
      });
    }
    String csvData = const ListToCsvConverter().convert(data);
    print(path);
    final File file = File(path);
    await file.writeAsString(csvData,mode: FileMode.writeOnlyAppend);

  }
}

