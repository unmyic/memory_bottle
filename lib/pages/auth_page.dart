import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
      } else {
        await Supabase.instance.client.auth.signUp(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = '网络错误，请检查连接');
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sailing,
                      size: 72, color: colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    '记忆漂流瓶',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '登录后即可云端同步记忆',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  // 错误提示
                  if (_error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(_error!,
                          style: TextStyle(color: Colors.red.shade700)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 邮箱
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: '邮箱',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      if (v == null || !v.contains('@')) return '请输入有效邮箱';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // 密码
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      labelText: '密码',
                      prefixIcon: Icon(Icons.lock_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 6) return '密码至少 6 位';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 登录/注册按钮
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2))
                          : Text(_isLogin ? '登录' : '注册'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 切换登录/注册
                  TextButton(
                    onPressed: () =>
                        setState(() { _isLogin = !_isLogin; _error = null; }),
                    child: Text(_isLogin ? '没有账号？点击注册' : '已有账号？点击登录'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
