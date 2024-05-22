import 'package:flutter/material.dart';
import 'package:trend_analysis/responsive/responsive.dart';
import 'package:trend_analysis/screens/chat_screen.dart';
import 'package:trend_analysis/screens/data_stats_screen.dart';
import 'package:trend_analysis/utils/colors.dart';
import 'package:trend_analysis/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class MainMenuScreen extends StatelessWidget {
  static String routeName = '/main-menu';
  const MainMenuScreen({Key? key}) : super(key: key);

  Widget _buildOption(BuildContext context, String imageUrl, String buttonText,
      VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Image.network(
                imageUrl,
                width: MediaQuery.of(context).size.width > 600
                    ? 500
                    : MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.35,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          CustomButton(
            onTap: onTap,
            text: buttonText,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.blueAccent, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'Home',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [bgColor, bgColor.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10.0,
        shadowColor: Colors.black54,
        centerTitle: true,
      ),
      body: Responsive(
        child: SingleChildScrollView(
          scrollDirection: MediaQuery.of(context).size.width > 600
              ? Axis.horizontal
              : Axis.vertical,
          child: MediaQuery.of(context).size.width > 600
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildOption(
                          context,
                          'https://ak.picdn.net/shutterstock/videos/7869652/thumb/1.jpg',
                          'Firebase based Statistics',
                          () async {
                            bool? result = await showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(
                                      'Note: The data stored in firebase is a subset of the whole dataset owing to subscriptions. Thus, the data would vary in statistics. Alright?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: const Text(
                                        'Yes',
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: const Text(
                                        'No',
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (result == true) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => trend_analysisScreen(
                                    isLocal: false,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildOption(
                          context,
                          'https://miro.medium.com/v2/resize:fit:720/0*UjBJ_iTNESi6Zevk.jpg',
                          'Local based Statistics',
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => trend_analysisScreen(
                                        isLocal: true,
                                      )),
                            );
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildOption(
                          context,
                          'https://c1.wallpaperflare.com/preview/653/576/854/question-mark-pile-question-mark.jpg',
                          'Contact us / ChatBot',
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ChatScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildFooter(),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildOption(
                      context,
                      'https://ak.picdn.net/shutterstock/videos/7869652/thumb/1.jpg',
                      'Firebase based Statistics',
                      () async {
                        bool? result = await showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                  'Note: The data stored in firebase is a subset of the whole dataset owing to subscriptions. Thus, the data would vary in statistics. Alright?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text(
                                    'Yes',
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text(
                                    'No',
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        if (result == true) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => trend_analysisScreen(
                                isLocal: false,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildOption(
                      context,
                      'https://miro.medium.com/v2/resize:fit:720/0*UjBJ_iTNESi6Zevk.jpg',
                      'Local based Statistics',
                      () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => trend_analysisScreen(
                                    isLocal: true,
                                  )),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildOption(
                      context,
                      'https://c1.wallpaperflare.com/preview/653/576/854/question-mark-pile-question-mark.jpg',
                      'Contact us / ChatBot',
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ChatScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildFooter(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: () async {
          // await saveDataToFirestore();
          const url = 'https://github.com/SanidhayaSharma141';
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url));
          } else {
            throw 'Could not launch $url';
          }
        },
        child: Column(
          children: [
            Divider(color: Colors.grey),
            Text(
              'Made with ❤ by Sanidhaya',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
