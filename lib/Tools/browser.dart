
import 'package:url_launcher/url_launcher.dart';


forgotMDP() async{
  await _launchURL("http://schoolapp.ensam-umi.ac.ma/schoolapp/register/forgot-password");
}

setBack() async{
  await _launchURL("https://documentation.onesignal.com/docs/notifications-show-successful-but-are-not-being-shown");
}

signUp() async{
  await _launchURL("http://schoolapp.ensam-umi.ac.ma/schoolapp/register/sign-up-student");
}

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
