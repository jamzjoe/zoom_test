import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:zoom/zoom.dart';

class JoinWidget extends StatefulWidget {
  @override
  _JoinWidgetState createState() => _JoinWidgetState();
}

class _JoinWidgetState extends State<JoinWidget> {
  TextEditingController meetingIdController = TextEditingController();
  TextEditingController meetingPasswordController = TextEditingController();
  late Timer timer;
  @override
  Widget build(BuildContext context) {
    // new page needs scaffolding!
    return Scaffold(
      appBar: AppBar(
        title: Text('Join meeting'),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 32.0,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                    controller: meetingIdController,
                    decoration: InputDecoration(
                      labelText: 'Meeting ID',
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                    controller: meetingPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Meeting Password',
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Builder(
                  builder: (context) {
                    // The basic Material Design action button.
                    return ElevatedButton(
                      // If onPressed is null, the button is disabled
                      // this is my goto temporary callback.
                      onPressed: () => joinMeeting(context),
                      child: Text('Join'),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Builder(
                  builder: (context) {
                    // The basic Material Design action button.
                    return ElevatedButton(
                      // If onPressed is null, the button is disabled
                      // this is my goto temporary callback.
                      onPressed: () => startMeeting(context),
                      child: Text('Start Meeting'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isMeetingEnded(String status) {
    if (Platform.isAndroid)
      return status == "MEETING_STATUS_DISCONNECTING" ||
          status == "MEETING_STATUS_FAILED";
    return status == "MEETING_STATUS_ENDED";
  }

  joinMeeting(BuildContext context) {
    ZoomOptions zoomOptions = new ZoomOptions(
      domain: "zoom.us",
      //https://marketplace.zoom.us/docs/sdk/native-sdks/auth
      //https://jwt.io/
      //--todo from server
      jwtToken:
          "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOm51bGwsImlzcyI6Ii02NWtwVDlCUVJHMzJqZlpENjVfUmciLCJleHAiOjE2NzkxMjg4MDAsImlhdCI6MTY3OTA0MjQwMX0.67O3e0bPw-9n4ufw_sB0HspQSG_ZagZ33l-OTW-Ne3c",
      appKey:
          "ISi5wEA9Qg6tfYqEhetwgQ", // Replace with with key got from the Zoom Marketplace ZOOM SDK Section
      appSecret:
          "rezmvCHAEZiFJ3bQwhxoZh7oG30CkOsY", // Replace with with secret got from the Zoom Marketplace ZOOM SDK Section
    );
    var meetingOptions = new ZoomMeetingOptions(
        userId: "",
        meetingId: meetingIdController.text,
        meetingPassword: meetingPasswordController.text,
        disableDialIn: "true",
        disableDrive: "true",
        disableInvite: "true",
        disableShare: "true",
        noAudio: "false",
        noDisconnectAudio: "false",
        meetingViewOptions: ZoomMeetingOptions.NO_TEXT_PASSWORD +
            ZoomMeetingOptions.NO_TEXT_MEETING_ID +
            ZoomMeetingOptions.NO_BUTTON_PARTICIPANTS);
    var zoom = Zoom();
    zoom.init(zoomOptions).then((results) {
      if (results[0] == 0) {
        zoom.onMeetingStateChanged.listen((status) {
          log("Meeting Status Stream: " + status[0] + " - " + status[1]);
          if (_isMeetingEnded(status[0])) {
            timer.cancel();
          }
        });
        zoom.joinMeeting(meetingOptions).then((joinMeetingResult) {
          timer = Timer.periodic(new Duration(seconds: 2), (timer) {
            zoom.meetingStatus(meetingOptions.meetingId).then((status) {
              log("Meeting Status Polling: " + status[0] + " - " + status[1]);
            });
          });
        });
      }
    });
  }

  startMeeting(BuildContext context) {}
}
