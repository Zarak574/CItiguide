package com.example.rolebase

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        SharedPreferencesPlugin.registerWith(flutterEngine.getDartExecutor().getBinaryMessenger());
    }
}