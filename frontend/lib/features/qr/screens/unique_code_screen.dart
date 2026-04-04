import 'package:flutter/material.dart';

class UniqueCodeScreen extends StatelessWidget {
	const UniqueCodeScreen({Key? key}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Unique Code')),
			body: const Center(
				child: Text('Unique code feature is available from QR workflows.'),
			),
		);
	}
}
