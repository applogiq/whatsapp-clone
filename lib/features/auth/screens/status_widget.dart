import 'package:flutter/material.dart';

class Status extends StatelessWidget {
  const Status({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          // ListTile(
          //   title: Text(
          //     "Ram",
          //   ),
          //   leading: CircleAvatar(
          //     backgroundImage: NetworkImage(
          //       "https://upload.wikimedia.org/wikipedia/commons/8/85/Elon_Musk_Royal_Society_%28crop1%29.jpg",
          //     ),
          //     radius: 30,
          //   ),
          // ),
          // SizedBox(
          //   height: 30,
          // ),
          ListTile(
            title: Text(
              "Gowtham",
            ),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                "https://img.jagranjosh.com/imported/images/E/GK/sachin-records.webp",
              ),
              radius: 30,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          ListTile(
            title: Text(
              "Praveen",
            ),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                "https://upload.wikimedia.org/wikipedia/commons/8/85/Elon_Musk_Royal_Society_%28crop1%29.jpg",
              ),
              radius: 30,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          ListTile(
            title: Text(
              "Naveen",
            ),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                "https://img.jagranjosh.com/imported/images/E/GK/sachin-records.webp",
              ),
              radius: 30,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          ListTile(
            title: Text(
              "Ajith",
            ),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                "https://upload.wikimedia.org/wikipedia/commons/8/85/Elon_Musk_Royal_Society_%28crop1%29.jpg",
              ),
              radius: 30,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          ListTile(
            title: Text(
              "Ajith",
            ),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                "https://img.jagranjosh.com/imported/images/E/GK/sachin-records.webp",
              ),
              radius: 30,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          ListTile(
            title: Text(
              "Ajith",
            ),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                "https://upload.wikimedia.org/wikipedia/commons/8/85/Elon_Musk_Royal_Society_%28crop1%29.jpg ",
              ),
              radius: 30,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          ListTile(
            title: Text(
              "Ajith",
            ),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                "https://img.jagranjosh.com/imported/images/E/GK/sachin-records.webp",
              ),
              radius: 30,
            ),
          ),
        ],
      ),
    );
  }
}
