import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bti_test_kosong_satu/constants.dart';
import 'package:bti_test_kosong_satu/services/fcm_services.dart';
import 'package:bti_test_kosong_satu/test_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final picker = ImagePicker();
  File? image;
  String? filenm;
  Position? _position;
  List<Widget> listObject = [];
  GlobalKey previewContainer = GlobalKey();
  int originalSize = 800;
  Image? gambar;
  Uint8List? imageFile;
  List<Album>? _albums;
  bool _loading = false;
  CameraPosition? googlePlex;
  List<Contact>? _contacts;
  bool _permissionDenied = false;
  String? tokenFcm;
  FcmServices fcmServices = FcmServices();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS &&
            await Permission.storage.request().isGranted &&
            await Permission.photos.request().isGranted ||
        Platform.isAndroid && await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);

        listObject.add(Padding(
          padding: const EdgeInsets.all(24.0),
          child: Image.file(File(pickedFile.path)),
        ));
      }
    });
    fcmServices.sendNotif(tokenFcm!, 'ada pesan', 'name');
  }

  Future getFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    final nameFile = result!.files.single.name;

    if (result != null) {
      image = File(result.files.single.path!);
      setState(() {
        filenm = nameFile;
      });
    }
    if (filenm != null) {
      documentsModal();
    }
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _position = position;
    });
    if (_position != null) {
      marker();
    }
  }

  Future<Position?> _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('Location Permission are denied');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> initAsync() async {
    if (await _promptPermissionSetting()) {
      List<Album> albums =
          await PhotoGallery.listAlbums(mediumType: MediumType.image);
      setState(() {
        _albums = albums;
        _loading = false;
      });
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _getCurrentLocation();
    initAsync();
    getToken();
    notif();

    FirebaseMessaging.onMessageOpenedApp.listen((event) {});
  }

  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _marker = [];

  void marker() {
    Marker marker = Marker(
      markerId: const MarkerId('1'),
      position: LatLng(_position!.latitude, _position!.longitude),
    );
    setState(() {
      _marker.add(marker);
    });
  }

  void takeSnapShot() async {
    GoogleMapController controller = await _controller.future;
    Future<void>.delayed(const Duration(milliseconds: 1000), () async {
      imageFile = await controller.takeSnapshot();
      setState(() {});
    });
  }

  Future _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
    } else {
      final contacts = await FlutterContacts.getContacts();
      setState(() => _contacts = contacts);
    }
  }

  void getToken() async {
    FirebaseMessaging.instance.getToken().then((value) {
      print(value);
      setState(() {
        tokenFcm = value;
      });
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message!.notification != null) {
        print(message.notification!.title);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      if (event.notification != null) {
        print(event.notification!.title);
      }
    });

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
  }

  void notif() {
    FirebaseMessaging.onMessage.listen((event) {
      print("onMessage: $event.");
      RemoteNotification? notification = event.notification;
      AndroidNotification? android = event.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'channel.id',
              ' channel.name',
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

  void documentsModal() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
              height: 200,
              child: Column(
                children: [
                  const Icon(
                    Icons.description,
                    size: 64,
                  ),
                  Text(filenm!),
                  ElevatedButton(
                      onPressed: () {
                        listObject.add(Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: SizedBox(
                            width: 100,
                            height: 150,
                            child: Center(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.description,
                                    size: 64,
                                  ),
                                  Text(filenm!)
                                ],
                              ),
                            ),
                          ),
                        ));

                        fcmServices.sendNotif(tokenFcm!, 'ada pesan', 'name');

                        setState(() {});
                        filenm = null;
                        Navigator.pop(context);
                      },
                      child: const Text('ok'))
                ],
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    print(listObject);
    if (_position != null) {
      final CameraPosition _kGooglePlex = CameraPosition(
        target: LatLng(_position!.latitude, _position!.longitude),
        zoom: 14.4746,
      );
      setState(() {
        googlePlex = _kGooglePlex;
      });
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    List<Widget> list = [
      GestureDetector(
        onTap: () {
          getImage();
        },
        child: Container(
          color: Colors.brown,
          child: Icon(Icons.photo_camera),
        ),
      ),
      GestureDetector(
        onTap: () {
          listObject.add(
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                child: Image.asset(
                  'assets/image.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
          fcmServices.sendNotif(tokenFcm!, 'ada pesan', 'name');
          setState(() {
            Navigator.pop(context);
          });
        },
        child: Container(
          child: Image.asset(
            'assets/image.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          listObject.add(Container(
            child: Image.asset(
              'assets/linux.png',
              fit: BoxFit.cover,
            ),
          ));
          setState(() {
            Navigator.pop(context);
          });
          fcmServices.sendNotif(tokenFcm!, 'ada pesan', 'name');
        },
        child: Container(
          child: Image.asset(
            'assets/linux.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          listObject.add(Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              child: Image.asset(
                'assets/image.png',
                fit: BoxFit.cover,
              ),
            ),
          ));
          setState(() {
            Navigator.pop(context);
          });
          fcmServices.sendNotif(tokenFcm!, 'ada pesan', 'name');
        },
        child: Container(
          child: Image.asset(
            'assets/image.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
      SizedBox(),
      SizedBox(),
      SizedBox(),
      SizedBox(),
      SizedBox(),
    ];

    void modalBottomSheet() {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return SizedBox(
              height: 360,
              child: GridView.builder(
                  itemCount: 9,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      // banyak grid yang ditampilkan dalam satu baris
                      crossAxisCount: 3),
                  itemBuilder: (context, index) {
                    return Container(
                      child: Card(
                        child: list[index],
                      ),
                    );
                  }),
            );
          });
    }

    void mapsModal() {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width,
                    child: RepaintBoundary(
                      key: previewContainer,
                      child: GoogleMap(
                        markers: _marker.toSet(),
                        initialCameraPosition: googlePlex!,
                        onMapCreated: (GoogleMapController controller) async {
                          _controller.complete(controller);
                          takeSnapShot();
                        },
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      listObject.add(
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: SizedBox(
                            child: Image.memory(
                              imageFile!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                      setState(() {});
                      Navigator.pop(context);
                      fcmServices.sendNotif(tokenFcm!, 'ada pesan', 'name');
                      print(imageFile);
                    },
                    child: Text('OK'),
                  )
                ],
              ),
            );
          });
    }

    void contactsModal() {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                  children: _contacts!.map((contact) {
                return GestureDetector(
                  onTap: () {
                    listObject.add(
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Container(
                          child: ListTile(
                            leading: CircleAvatar(),
                            title: Text(contact.displayName),
                          ),
                        ),
                      ),
                    );
                    setState(() {});
                    fcmServices.sendNotif(tokenFcm!, 'ada pesan', 'name');
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(),
                        title: Text(contact.displayName),
                        subtitle: Text('${contact.phones}'),
                      ),
                    ),
                  ),
                );
              }).toList()),
            );
          });
    }

    Widget header() {
      return Container(
        height: MediaQuery.of(context).size.height * 0.09,
        width: MediaQuery.of(context).size.width,
        color: Colors.greenAccent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    listObject.clear();
                  });
                  fcmServices.sendNotif(tokenFcm!, 'ada pesan', 'name');
                },
                icon: Icon(Icons.arrow_back_ios),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.person),
              ),
              const SizedBox(
                width: 5,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Arif Yusuf',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'last seen 15:27',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TestPage()));
                      },
                      child: Icon(Icons.phone)),
                  const SizedBox(
                    width: 10,
                  ),
                  const Icon(Icons.more_vert)
                ],
              )
            ],
          ),
        ),
      );
    }

    Widget bottomMenu() {
      return Container(
        color: Colors.greenAccent,
        height: MediaQuery.of(context).size.height * 0.12,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  modalBottomSheet();
                },
                child: Column(
                  children: const [
                    Icon(
                      Icons.image,
                      size: 36,
                    ),
                    Text('Gallery')
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  getFile();
                },
                child: Column(
                  children: const [
                    Icon(
                      Icons.description,
                      size: 36,
                    ),
                    Text('Document')
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  mapsModal();
                },
                child: Column(
                  children: const [
                    Icon(
                      Icons.room,
                      size: 36,
                    ),
                    Text('Location')
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  _fetchContacts();
                  contactsModal();
                },
                child: Column(
                  children: const [
                    Icon(
                      Icons.person,
                      size: 36,
                    ),
                    Text('Contact')
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  getFile();
                },
                child: Column(
                  children: const [
                    Icon(
                      Icons.play_arrow,
                      size: 36,
                    ),
                    Text('Audio')
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              header(),
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.78,
                  child: ListView(
                    children: listObject
                        // .map((e) => Card(
                        //       child:
                        //           SizedBox(width: 100, height: 200, child: e),
                        //     ))
                        // .toList(),
                        .map((e) => Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Card(
                                  child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: e,
                              )),
                            ))
                        .toList(),
                  )),
              bottomMenu()
            ],
          ),
        ),
      ),
    );
  }
}
