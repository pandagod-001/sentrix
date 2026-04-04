import 'package:flutter/material.dart';

class NotFoundScreen extends StatelessWidget {
	const NotFoundScreen({Key? key}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Not Found')),
			body: const Center(
				child: Text('The requested page was not found.'),
			),
		);
	}
}
