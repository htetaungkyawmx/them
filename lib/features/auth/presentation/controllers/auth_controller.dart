import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  var isLoading = false.obs;
  var user = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    user.value = _auth.currentUser;
  }

  // Email/Password Login
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      user.value = userCredential.user;
      Get.offAllNamed('/home');

    } on FirebaseAuthException catch (e) {
      String message = 'အကောင့်ဝင်ရောက်ရန် မအောင်မြင်ပါ';
      if (e.code == 'user-not-found') {
        message = 'အီးမေးလ် မှားယွင်းနေပါသည်';
      } else if (e.code == 'wrong-password') {
        message = 'စကားဝှက် မှားယွင်းနေပါသည်';
      }
      Get.snackbar(
        'အမှား',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Google Sign In
  Future<void> googleSignIn() async {
    try {
      isLoading.value = true;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      user.value = userCredential.user;
      Get.offAllNamed('/home');

    } catch (e) {
      Get.snackbar(
        'အမှား',
        'Google အကောင့်ဖြင့် ဝင်ရောက်ရန် မအောင်မြင်ပါ',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    user.value = null;
    Get.offAllNamed('/login');
  }
}