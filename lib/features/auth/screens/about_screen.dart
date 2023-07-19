import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_ui/common/config/size_config.dart';
import 'package:whatsapp_ui/common/config/text_style.dart';
import 'package:whatsapp_ui/common/utils/toast_message.dart';
import 'package:whatsapp_ui/common/widgets/box/vertical_box.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/auth/screens/profile_screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  List<String> aboutDefaultDialogues = [
    "Available",
    "Busy",
    "At school",
    "At the movies",
    "At work",
    "Battery about to die",
    "Cant't talk applogiq only",
    "In a meeting",
    "at the gym",
    "Sleeping",
    "Urgent calls only"
  ];
  final TextEditingController _aboutStatusController = TextEditingController();

  final userDocRef = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser?.uid);

  void updateAboutStatus(String aboutStatus) async {
    await userDocRef.update({'aboutStatus': aboutStatus}).then((_) {
      // Update successful
      toastMessage(
          "About status updated successfully!", Colors.green, Colors.white);

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()));
    }).catchError((error) {
      // Handle update error
      print('Error updating about status: $error');
    });
  }

  @override
  void initState() {
    super.initState();
    _aboutStatusController.text =
        ""; // Add your code to fetch the current about status here
  }

  @override
  void dispose() {
    // TODO: implement dispose

    _aboutStatusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 15,
            ),
            Text(
              "Currently Set to",
              style: authScreenheadingStyle().copyWith(fontSize: 18),
            ),
            const VerticalBox(height: 10),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Loader(); // Return an empty widget or show an error message
                  }
                  var data = snapshot.data!;
                  return Text(data['aboutStatus']);
                }),
            const SizedBox(
              height: 15,
            ),
            Text(
              "Edit About status",
              style: authScreenheadingStyle().copyWith(fontSize: 18),
            ),
            const VerticalBox(height: 10),
            SizedBox(
              height: getProportionateScreenHeight(45),
              width: double.infinity,
              child: TextField(
                controller: _aboutStatusController,
                decoration: InputDecoration(
                  fillColor: const Color.fromRGBO(242, 242, 242, 1),
                  filled: true,
                  hintText: "Type here...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(10, 12, 0, 0),
                ),
                cursorWidth: 1.2,
                cursorColor: Colors.black,
                keyboardType: TextInputType.name,
                inputFormatters: const [],
                onChanged: (value) {
                  // Do nothing for now, as we want to update only when saving
                },
                style: authScreensubTitleStyle().copyWith(fontSize: 15),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  updateAboutStatus(_aboutStatusController.text);
                  _aboutStatusController.text = '';
                  setState(() {});
                },
                child: Container(
                  height: 40,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.red,
                  ),
                  child: const Center(
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              "Select About",
              style: authScreenheadingStyle().copyWith(fontSize: 18),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: aboutDefaultDialogues.length,
                itemBuilder: (context, index) {
                  final about = aboutDefaultDialogues[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _aboutStatusController.text = about;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        about.toString(),
                        style: authScreensubTitleStyle(),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}



  // getCurrentUserAboutStatus() {
  //   FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(FirebaseAuth.instance.currentUser?.uid)
  //       .get()
  //       .then((DocumentSnapshot<Map<String, dynamic>> snapshot) {
  //     if (snapshot.exists) {
  //       var userData = snapshot.data();
  //       aboutStatus = userData?['aboutStatus'];
  //       print("User's about status: $aboutStatus");
  //       // Do whatever you need with the about status value
  //     } else {
  //       aboutStatus = "Hey there i am using Applogiq";
  //     }
  //   }).catchError((error) {
  //     print("Error retrieving user data: $error");
  //   });
  //   setState(() {});
  // }