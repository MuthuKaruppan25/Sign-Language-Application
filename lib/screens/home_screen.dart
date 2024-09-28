//Package imports
import 'package:flutter/material.dart';
import 'package:meet/main.dart';
import 'package:meet/models/data_store.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

//File imports
import 'package:meet/screens/meeting_screen.dart';
import 'package:meet/services/join_service.dart';
import 'package:meet/services/sdk_initializer.dart';

var x="";

class HomeScreen1 extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserDataStore _dataStore;
  bool _isLoading = false;

  @override
  void initState() {
    getPermissions();
    super.initState();
  }

  void getPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();

    while ((await Permission.camera.isDenied)) {
      await Permission.camera.request();
    }
    while ((await Permission.microphone.isDenied)) {
      await Permission.microphone.request();
    }
  }

  //Handles room joining functionality
  Future<bool> joinRoom() async {
    setState(() {
      _isLoading = true;
    });
    //The join method initialize sdk,gets auth token,creates HMSConfig and helps in joining the room
    await SdkInitializer.hmssdk.build();
    _dataStore = UserDataStore();

    
    //Here we are attaching a listener to our DataStoreClass
    _dataStore.startListen();
    print(SdkInitializer.hmssdk.appGroup);
    bool isJoinSuccessful = await JoinService.join(SdkInitializer.hmssdk);
    if (!isJoinSuccessful) {
      return false;
    }
    setState(() {
      _isLoading = false;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(

      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text("Meet",style:TextStyle(color: Colors.white)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {},
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: const Text(
                  'Google Meet',
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
              ),
              ListTile(
                title: Row(
                  children: const [
                    Icon(Icons.settings_outlined),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Settings'),
                  ],
                ),
                onTap: () {},
              ),
              ListTile(
                title: Row(
                  children: const [
                    Icon(Icons.feedback_outlined),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Send feedback'),
                  ],
                ),
                onTap: () {},
              ),
              ListTile(
                title: Row(
                  children: const [
                    Icon(Icons.help_outline),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Help'),
                  ],
                ),
                onTap: () {},
              ),
            ],
          ), // Populate the Drawer in the next step.
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return SizedBox(
                          height: 200,
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: <Widget>[
                              ListTile(
                                title: Row(
                                  children: const [
                                    Icon(Icons.video_call),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('Start an instant meeting'),
                                  ],
                                ),
                                onTap: () async {
                                  bool isJoined = await joinRoom();
                                  if (isJoined) {
                                    
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (_) =>
                                            ListenableProvider.value(
                                                value: _dataStore,
                                                child: const MeetingScreen())));
                                  } else {
                                    const SnackBar(content: Text("Error"));
                                  }
                                },
                              ),
                              ListTile(
                                title: Row(
                                  children: const [
                                    Icon(Icons.close),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('Close'),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: const Text('New meeting'),
                ),
                OutlinedButton(
                    style: Theme.of(context)
                        .outlinedButtonTheme
                        .style!
                        .copyWith(
                            side: MaterialStateProperty.all(
                                const BorderSide(color: Colors.black)),
                            backgroundColor: MaterialStateColor.resolveWith(
                                (states) => Colors.black),
                            foregroundColor: MaterialStateColor.resolveWith(
                                (states) => Colors.white)),
                    onPressed: () {},
                    child: const Text('Join with a code'))
              ],
            )
          ],
        ),
      ),
    );
  }
}
