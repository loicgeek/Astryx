import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/widgets.dart';

/// The data captured by [AstryxSignupFormTemplate].
typedef AstryxSignupData = ({String email, bool acceptedTerms});

/// {@template astryx.signupformtemplate}
/// A ready-made sign-up form: an email field, a terms checkbox, and a submit
/// button that's disabled until the terms are accepted. Calls [onSubmit] with
/// the captured data.
/// {@endtemplate}
class AstryxSignupFormTemplate extends StatefulWidget {
  const AstryxSignupFormTemplate({super.key, this.onSubmit, this.title = 'Create your account'});

  final ValueChanged<AstryxSignupData>? onSubmit;
  final String title;

  @override
  State<AstryxSignupFormTemplate> createState() => _AstryxSignupFormTemplateState();
}

class _AstryxSignupFormTemplateState extends State<AstryxSignupFormTemplate> {
  final _email = TextEditingController();
  bool _terms = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _email.text.trim();
    if (!email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    setState(() => _error = null);
    widget.onSubmit?.call((email: email, acceptedTerms: _terms));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: t.spacing.gapLg,
        children: [
          AstryxHeading(widget.title, level: AstryxHeadingLevel.h1),
          AstryxField(
            label: 'Email',
            required: true,
            error: _error,
            child: AstryxTextInput(
              controller: _email,
              hintText: 'you@example.com',
              hasError: _error != null,
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          AstryxCheckbox(
            value: _terms,
            label: 'I agree to the terms of service',
            onChanged: (v) => setState(() => _terms = v),
          ),
          AstryxButton(
            label: 'Sign up',
            expand: true,
            onPressed: _terms ? _submit : null,
          ),
        ],
      ),
    );
  }
}
