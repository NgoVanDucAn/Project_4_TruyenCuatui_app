import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truyencuatui/config/Palette.dart';
import 'package:truyencuatui/screens/change_password_screen.dart';
import 'package:truyencuatui/screens/novel.dart';
import 'package:truyencuatui/service/AuthService.dart';
import 'package:truyencuatui/service/LoginService.dart';
import 'package:truyencuatui/service/signup.dart';

final isUserLoginProvider = StateProvider((ref) => false);

class LoginSignupScreen extends ConsumerStatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  ConsumerState createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends ConsumerState<LoginSignupScreen> {
  bool isMale = true;
  bool isRememberMe = true;
  bool isSignupScreen = false;
  LoginService loginService = LoginService();
  AuthService authService = AuthService();
  SignUpService signUpService = SignUpService();
  late Map<String, String> tokens;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _loginError = '';

  Future<void> _handleLogin({required WidgetRef ref}) async {
    String userName = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if (userName.isEmpty || password.isEmpty) {
      if (mounted) {
        setState(() {
          _loginError = 'Username and password cannot be empty.';
        });
      }
      return;
    }
    try {
      // Use _loginService to call loginUser function
      await loginService.loginUser(userName, password);
      // After the login, get the tokens
      tokens = await authService.getToken();
      // Check if accessToken is not null
      if (tokens['accessToken'] != null) {
        Future.delayed(const Duration(microseconds: 500), () {
          ref.read(isUserLoginProvider.notifier).state = true;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const NovelScreen()),
          );
        });
      } else {
        if (mounted) {
          setState(() {
            _loginError = 'Invalid username or password.';
          });
        }
      }
      Future.delayed(const Duration(microseconds: 500), () {
        ref.read(isUserLoginProvider.notifier).state = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NovelScreen()),
        );
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loginError = 'Failed to login: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _handleSignup({required WidgetRef ref}) async {
  String email = _emailController.text.trim();  // Sử dụng controller riêng cho email
  String password = _passwordController.text.trim();
  if (email.isEmpty || password.isEmpty) {
    setState(() {
      _loginError = 'Email and password cannot be empty.';
    });
    return;
  }
  try {
    var result = await signUpService.registerUser(email, password);
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup successful! Please login.')),
      );
      setState(() {
        isSignupScreen = false;  // Chuyển sang màn hình đăng nhập
      });
    } else {
      setState(() {
        _loginError = result['message'];
      });
    }
  } catch (e) {
    setState(() {
      _loginError = 'Failed to signup: ${e.toString()}';
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: Stack(
        children: [
          // Nếu có một hình nền màu sáng, thử đổi màu icon để nó nổi bật hơn
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.only(top: 90, left: 20),
                color: const Color(0xff3b59999).withOpacity(.85),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NovelScreen()),
                        );
                      },
                      child: const Icon(
                        Icons.home, // Thay đổi icon này theo ý thích của bạn
                        color: Colors.white,
                        size: 50.0,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "Wecome to",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          letterSpacing: 2,
                        ),
                        children: [
                          TextSpan(
                            text: isSignupScreen ? 'Truyện Cua Tui,' : "Back",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isSignupScreen
                          ? "Signup to Continue"
                          : "Signin to Continue",
                      style: const TextStyle(
                        color: Colors.red,
                        letterSpacing: 1,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          BuildBottomPositioned(true, ref),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 80),
            curve: Curves.bounceInOut,
            top: isSignupScreen ? 200 : 250,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              curve: Curves.bounceInOut,
              height: isSignupScreen ? 400 : 300,
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width - 40,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() => isSignupScreen = false);
                          },
                          child: Column(
                            children: [
                              Text(
                                "LOGIN",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: !isSignupScreen
                                      ? Palette.textColor1
                                      : Palette.activeColor,
                                ),
                              ),
                              if (!isSignupScreen)
                                Container(
                                  margin: const EdgeInsets.only(top: 3),
                                  height: 2,
                                  width: 55,
                                  color: Colors.orange,
                                )
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => isSignupScreen = true);
                          },
                          child: Column(
                            children: [
                              Text(
                                "SIGNUP",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSignupScreen
                                      ? Palette.textColor2
                                      : Palette.activeColor,
                                ),
                              ),
                              if (isSignupScreen)
                                Container(
                                  margin: const EdgeInsets.only(top: 3),
                                  height: 2,
                                  width: 55,
                                  color: Colors.orange,
                                )
                            ],
                          ),
                        )
                      ],
                    ),
                    if (isSignupScreen) BuildSignupScreen(),
                    if (!isSignupScreen) BuildSigninScreen()
                  ],
                ),
              ),
            ),
          ),
          BuildBottomPositioned(false, ref),
          Positioned(
            top: MediaQuery.of(context).size.height - 100,
            right: 0,
            left: 0,
            child: Column(
              children: [
                const Text("Or Signup with"),
                Container(
                  margin: const EdgeInsets.only(right: 20, left: 20, top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      BuildTextButton(Icons.facebook_outlined, "Facebook",
                          Palette.facebookColor),
                      BuildTextButton(
                          Icons.email, "Google", Palette.googleColor),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Container BuildSigninScreen() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          buildTextField(
              Icons.email, "abc@example.com", false, true, _emailController),
          buildTextField(Icons.lock_outline, "**********", true, false,
              _passwordController),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                value: isRememberMe,
                activeColor: Palette.textColor2,
                onChanged: (value) {
                  setState(() {
                    isRememberMe = !isRememberMe;
                  });
                },
              ),
              Container(
                child: const Text(
                  "Remember Me",
                  style: TextStyle(
                    color: Palette.textColor1,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
          Container(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen()),
                );
              },
              child: const Text(
                "Forgot Password ?",
                style: TextStyle(
                  color: Palette.textColor1,
                  fontSize: 14,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Container BuildSignupScreen() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          buildTextField(Icons.email, "Email", false, true, _emailController),
          buildTextField(
              Icons.lock_outline, "Password", true, false, _passwordController),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isMale = true;
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color:
                              isMale ? Palette.textColor2 : Colors.transparent,
                          border: Border.all(
                            width: 1,
                            color: isMale
                                ? Colors.transparent
                                : Palette.textColor2,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.account_circle_rounded,
                          color: isMale ? Colors.white : Palette.iconColor,
                        ),
                      ),
                      const Text(
                        "Male",
                        style: TextStyle(
                          color: Palette.textColor1,
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isMale = false;
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color:
                              isMale ? Colors.transparent : Palette.textColor2,
                          border: Border.all(
                            width: 1,
                            color: isMale
                                ? Palette.textColor1
                                : Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.account_circle_rounded,
                          color: isMale ? Palette.iconColor : Colors.white,
                        ),
                      ),
                      const Text(
                        "Female",
                        style: TextStyle(
                          color: Palette.textColor1,
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            width: 200,
            margin: const EdgeInsets.only(top: 20),
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                text: "By pressing 'Submit' you agree to our",
                style: TextStyle(
                  color: Palette.textColor2,
                ),
                children: [
                  TextSpan(
                    text: " term & conditions ",
                    style: TextStyle(
                      color: Colors.orange,
                    ),
                  ),
                  TextSpan(
                    text: "Terms of Use",
                    style: TextStyle(
                      color: Palette.textColor2,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  TextButton BuildTextButton(
      IconData icon, String title, Color backgroundColor) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        side: const BorderSide(width: 1, color: Colors.grey),
        minimumSize: const Size(145, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Palette.facebookColor,
      ),
      child: const Row(
        children: [
          Icon(Icons.facebook_outlined),
          SizedBox(
            width: 5,
          ),
          Text("Facebook"),
        ],
      ),
    );
  }

  AnimatedPositioned BuildBottomPositioned(bool showShadow, WidgetRef ref) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.bounceInOut,
      top: isSignupScreen ? 550 : 510,
      right: 0,
      left: 0,
      child: Center(
        child: GestureDetector(
          onTap: () {
            if (!isSignupScreen) {
              // Nếu không phải là màn hình đăng ký, thực hiện đăng nhập
              _handleLogin(ref: ref);
              print("login");
            } else {
              _handleSignup(ref: ref);
              print("signup");
            }
          },
          child: Container(
            height: 90,
            width: 90,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                if (showShadow)
                  BoxShadow(
                    color: Colors.black.withOpacity(.3),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  )
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF914D), Color(0xFFFF0000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  if (showShadow)
                    BoxShadow(
                      color: Colors.black.withOpacity(.3),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    )
                ],
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(IconData icon, String hintText, bool isPassword,
      bool isEmail, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Palette.iconColor,
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Palette.textColor1,
            ),
            borderRadius: BorderRadius.all(Radius.circular(35.0)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Palette.textColor1,
            ),
            borderRadius: BorderRadius.all(Radius.circular(35.0)),
          ),
          contentPadding: const EdgeInsets.all(10),
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 14, color: Palette.textColor1),
        ),
      ),
    );
  }
}
