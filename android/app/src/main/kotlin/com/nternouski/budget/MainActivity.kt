package com.nternouski.budget

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;
import io.flutter.plugins.GeneratedPluginRegistrant;

class MainActivity: FlutterFragmentActivity() {
	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		GeneratedPluginRegistrant.registerWith(flutterEngine);

		// TODO: Register the ListTileNativeAdFactory
		GoogleMobileAdsPlugin.registerNativeAdFactory(
			flutterEngine, "listTile", ListTileNativeAdFactory(applicationContext))
	}

	override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
		super.cleanUpFlutterEngine(flutterEngine)

		// TODO: Unregister the ListTileNativeAdFactory
		GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTile")
	}
}
