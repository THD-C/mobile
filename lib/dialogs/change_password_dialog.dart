import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/tools/api_servicer/api_user.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _changePasswordForm = GlobalKey<FormState>();
  late final TextEditingController old_password = TextEditingController();
  late final TextEditingController new_password = TextEditingController();
  late final TextEditingController new_password_confirmation = TextEditingController();

  bool _isLoading = false;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    old_password.dispose();
    new_password.dispose();
    new_password_confirmation.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (_changePasswordForm.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
          _passwordError = null;
        });

        if (new_password.text != new_password_confirmation.text){
          setState(() {
            _passwordError = AppLocalizations.of(
                        context,
                      ).translate("register_password_confirmation_failed");
            _isLoading = false;
          });
          
          return;
        }

        final updatedData = {
          'old_password': old_password.text,
          'new_password': new_password.text,
        };

        await UserApiService().updatePassword(updatedData, context);
        setState(() {
          _isLoading = false;
        });

        if(mounted){
          Navigator.pop(context, true);
        }
      } catch (e) {
        setState(() {
          _passwordError = AppLocalizations.of(context).translate("$e");
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).translate("change_password")),
      content: SingleChildScrollView(
        child: Form(
          key: _changePasswordForm,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: old_password,
                  decoration: InputDecoration(
                    labelText: (AppLocalizations.of(
                      context,
                    ).translate("change_password_old_password")),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(
                        context,
                      ).translate("fill_all_fields");
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                TextFormField(
                  controller: new_password,
                  decoration: InputDecoration(
                    labelText: (AppLocalizations.of(
                      context,
                    ).translate("change_password_new_password")),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(
                        context,
                      ).translate("fill_all_fields");
                    } else if (value.length < 12) {
                      return AppLocalizations.of(
                        context,
                      ).translate("register_password_too_short");
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                TextFormField(
                  controller: new_password_confirmation,
                  decoration: InputDecoration(
                    labelText: (AppLocalizations.of(
                      context,
                    ).translate("change_password_new_password_confirmation")),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(
                        context,
                      ).translate("fill_all_fields");
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      child: Text(
                        AppLocalizations.of(context).translate("edit_cancel"),
                        ),
                      ),
                      
                    
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _isLoading ? null : _updatePassword,
                      child: _isLoading 
                      ? const CircularProgressIndicator() 
                      : Text(
                        AppLocalizations.of(context).translate("edit_save")
                      ),
                    
                    ),
                  ],
                ),
                if (_passwordError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _passwordError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [],
    );
  }
}
