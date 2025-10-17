// Mengimpor paket-paket yang diperlukan untuk halaman ini.
import 'package:flutter/material.dart'; // Paket dasar untuk membangun UI Flutter.
import 'package:lottie/lottie.dart'; // Untuk menampilkan animasi Lottie.
import 'package:provider/provider.dart'; // Untuk state management, khususnya mengambil AuthService.
import 'package:absensi_admin/services/auth_service.dart'; // Layanan yang menangani logika autentikasi.
import 'package:absensi_admin/widgets/custom_input.dart'; // Widget kustom untuk input teks.
import 'package:absensi_admin/widgets/custom_button.dart'; // Widget kustom untuk tombol.

// LoginPage adalah StatefulWidget karena state-nya perlu berubah,
// misalnya untuk menampilkan loading indicator (_isLoading).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // GlobalKey untuk mengidentifikasi Form dan melakukan validasi.
  final _formKey = GlobalKey<FormState>();

  // Controller untuk mengambil teks dari setiap TextField.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variabel state untuk mengontrol tampilan loading pada tombol.
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(args), backgroundColor: Colors.red),
        );
      }
    });
  }

  // Fungsi yang dieksekusi ketika tombol login ditekan.
  Future<void> _login() async {
    // 1. Validasi Form: Jika input tidak valid (misal, email kosong), hentikan proses.
    if (!_formKey.currentState!.validate()) return;

    // 2. Ubah State: Tampilkan loading indicator di tombol.
    setState(() {
      _isLoading = true;
    });

    // 3. Panggil AuthService: Ambil instance AuthService menggunakan Provider.
    // `listen: false` digunakan karena kita hanya memanggil method, tidak perlu rebuild widget ini jika ada perubahan di AuthService.
    final authService = Provider.of<AuthService>(context, listen: false);

    // 4. Lakukan Login: Panggil method signIn dari authService dengan data dari controller.
    // PERHATIAN: Mengirim username dan email sekaligus bisa membingungkan dan menyebabkan kegagalan
    // jika logic di backend tidak ditangani dengan benar. Sebaiknya pilih salah satu (email saja).
    final success = await authService.signIn(
      _emailController.text,
      _passwordController.text,
    );

    // 5. Cek 'mounted': Praktik terbaik untuk memastikan widget masih ada di tree
    // sebelum melakukan operasi context seperti navigasi atau menampilkan SnackBar.
    if (!mounted) return;

    // 6. Proses Hasil Login:
    if (success) {
      // Jika berhasil, navigasi ke MainPage dan hapus halaman login dari tumpukan navigasi.
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // Jika gagal, tampilkan pesan error menggunakan SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please check your credentials.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // 7. Selesaikan Loading: Sembunyikan loading indicator setelah proses selesai.
    // Pengecekan 'mounted' di sini juga merupakan praktik yang baik.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // SingleChildScrollView agar UI bisa di-scroll jika keyboard muncul dan menutupi input.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          // Widget Form untuk mengelompokkan dan memvalidasi input field.
          child: Form(
            key: _formKey, // Menghubungkan Form dengan GlobalKey.
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animasi untuk mempercantik tampilan.
                Lottie.network(
                  'https://lottie.host/b08a34f5-2747-4185-b1a8-92a808f23945/V89Vxtz2o2.json',
                  height: 200,
                ),
                const SizedBox(height: 20),

                // Input field untuk Email dengan validasi format.
                CustomInput(
                  controller: _emailController,
                  hintText: 'Email',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Input field untuk Password dengan validasi panjang karakter.
                CustomInput(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: true, // Menyembunyikan teks password.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Tombol login kustom yang bisa menampilkan state loading.
                CustomButton(
                  onPressed: _login, // Memanggil fungsi _login saat ditekan.
                  text: 'Login',
                  isLoading: _isLoading, // Mengikat tampilan tombol dengan state _isLoading.
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}