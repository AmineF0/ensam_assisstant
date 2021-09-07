
import 'package:url_launcher/url_launcher.dart';


forgotMDP() async{
  _launchURL("http://schoolapp.ensam-umi.ac.ma/schoolapp/register/forgot-password");
}

signUp() async{
  _launchURL("http://schoolapp.ensam-umi.ac.ma/schoolapp/register/sign-up-student");
}

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
