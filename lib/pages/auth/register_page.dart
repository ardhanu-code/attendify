import 'package:attendify/const/app_color.dart';
import 'package:attendify/models/batches_models.dart';
import 'package:attendify/models/trainings_model.dart';
import 'package:attendify/services/auth_services.dart';
import 'package:attendify/services/get_batches_services.dart';
import 'package:attendify/services/get_trainings_services.dart';
import 'package:attendify/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedGender;
  BatchesData? _selectedBatch;
  DataTrainings? _selectedTraining;

  bool _isLoading = true;
  bool isVisiblePassword = true;
  bool isVisibleConfirmPassword = true;

  final List<Map<String, String>> _genderOptions = [
    {'label': 'Male', 'value': 'L'},
    {'label': 'Female', 'value': 'P'},
  ];

  List<BatchesData> _batchesList = [];
  List<DataTrainings> _trainingList = [];
  String? _genderErrorText;

  @override
  void initState() {
    super.initState();
    _getTrainingsList();
    _getBatchesList();
  }

  void _getTrainingsList() async {
    try {
      TrainingsResponse trainingsResponse =
          await TrainingsServices.fetchTrainings();
      setState(() {
        _trainingList = trainingsResponse.data;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _getBatchesList() async {
    try {
      BatchesResponse batchesResponse = await BatchesServices.fetchBatches();
      setState(() {
        _batchesList = batchesResponse.data;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister() async {
    if (!((_formKey.currentState?.validate() ?? false) && _validateGender()))
      return;

    if (_selectedBatch == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select your batch')));
      return;
    }
    if (_selectedTraining == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your training')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColor.primary),
      ),
    );

    try {
      await registerUser(
        _usernameController.text,
        _emailController.text.trim(),
        _passwordController.text,
        _selectedGender ?? '',
        '',
        '',
        _selectedBatch!.id,
        _selectedTraining!.id,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! Please login.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    }
  }

  bool _validateGender() {
    if (_selectedGender == null) {
      setState(() => _genderErrorText = 'Please select your gender');
      return false;
    } else {
      setState(() => _genderErrorText = null);
      return true;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.text,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset(
                  'assets/logo/attendify_black.png',
                  height: 150,
                  width: 150,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Create your account',
                    style: GoogleFonts.lexend(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _usernameController,
                  Icons.person_outline,
                  'Username',
                  (val) => val == null || val.isEmpty
                      ? 'Please enter your username'
                      : val.length < 3
                      ? 'Username must be at least 3 characters'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _emailController,
                  Icons.email_outlined,
                  'Email',
                  (val) => val == null || val.isEmpty
                      ? 'Please enter your email'
                      : !val.contains('@')
                      ? 'Please enter a valid email'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  _passwordController,
                  'Password',
                  isVisiblePassword,
                  () => setState(() => isVisiblePassword = !isVisiblePassword),
                  (val) => val == null || val.isEmpty
                      ? 'Please enter your password'
                      : val.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  _confirmPasswordController,
                  'Confirm Password',
                  isVisibleConfirmPassword,
                  () => setState(
                    () => isVisibleConfirmPassword = !isVisibleConfirmPassword,
                  ),
                  (val) => val != _passwordController.text
                      ? 'Passwords do not match'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildGenderSelection(),
                const SizedBox(height: 16),
                _isLoading || _batchesList.isEmpty
                    ? const CircularProgressIndicator()
                    : _buildDropdown<BatchesData>(
                        label: 'Select Batch',
                        icon: Icons.group_outlined,
                        value: _selectedBatch,
                        items: _batchesList,
                        display: (item) => item.batchKe,
                        onChanged: (val) =>
                            setState(() => _selectedBatch = val),
                      ),
                const SizedBox(height: 16),
                _isLoading || _trainingList.isEmpty
                    ? const CircularProgressIndicator()
                    : _buildDropdown<DataTrainings>(
                        label: 'Select Training',
                        icon: Icons.school_outlined,
                        value: _selectedTraining,
                        items: _trainingList,
                        display: (item) => item.title,
                        onChanged: (val) =>
                            setState(() => _selectedTraining = val),
                      ),
                const SizedBox(height: 34),
                CustomButton(
                  onPressed: _handleRegister,
                  text: 'REGISTER',
                  textStyle: GoogleFonts.lexend(),
                  backgroundColor: AppColor.primary,
                  height: 54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    IconData icon,
    String hintText,
    String? Function(String?)? validator,
  ) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderSide: BorderSide.none),
        hintStyle: GoogleFonts.lexend(fontSize: 14),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String hintText,
    bool isVisible,
    VoidCallback toggle,
    String? Function(String?)? validator,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: isVisible,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outlined),
        hintText: hintText,
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderSide: BorderSide.none),
        hintStyle: GoogleFonts.lexend(fontSize: 14),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: GoogleFonts.lexend(fontSize: 14, color: Colors.grey.shade700),
        ),
        ..._genderOptions.map(
          (option) => RadioListTile<String>(
            title: Text(
              option['label']!,
              style: GoogleFonts.lexend(fontSize: 14),
            ),
            value: option['value'] ?? 'Not Choosen',
            groupValue: _selectedGender,
            activeColor: AppColor.primary,
            onChanged: (val) => setState(() {
              _selectedGender = val;
              _genderErrorText = null;
            }),
          ),
        ),
        if (_genderErrorText != null)
          Text(
            _genderErrorText!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required String Function(T) display,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderSide: BorderSide.none),
        labelStyle: GoogleFonts.lexend(fontSize: 14, color: Colors.grey[800]),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                display(item),
                style: GoogleFonts.lexend(fontSize: 14),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Please select $label' : null,
    );
  }
}
