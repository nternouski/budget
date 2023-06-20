// TODO: Implement ListTileNativeAdFactory class

package com.nternouski.budget

import android.content.Context
import android.graphics.Color
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class ListTileNativeAdFactory(private val context: Context) : GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val nativeAdView = LayoutInflater.from(context)
            .inflate(R.layout.list_tile_native_ad, null) as NativeAdView

        with(nativeAdView) {
            val attributionViewSmall =
                findViewById<TextView>(R.id.tv_list_tile_native_ad_attribution_small)
            val attributionViewLarge =
                findViewById<TextView>(R.id.tv_list_tile_native_ad_attribution_large)

            val iconView = findViewById<ImageView>(R.id.iv_list_tile_native_ad_icon)
            val icon = nativeAd.icon
            if (icon != null) {
                attributionViewSmall.visibility = View.VISIBLE
                attributionViewLarge.visibility = View.INVISIBLE
                iconView.setImageDrawable(icon.drawable)
            } else {
                attributionViewSmall.visibility = View.INVISIBLE
                attributionViewLarge.visibility = View.VISIBLE
            }
            this.iconView = iconView

            val headlineView = findViewById<TextView>(R.id.tv_list_tile_native_ad_headline);
            var darkMode: Boolean = if (customOptions == null) true else customOptions["darkMode"] == true;
            headlineView.setTextColor(Color.parseColor(if (darkMode) "#FFFFFF" else "#000000"));
            headlineView.text = nativeAd.headline
            this.headlineView = headlineView

            val bodyView = findViewById<TextView>(R.id.tv_list_tile_native_ad_body)
            with(bodyView) {
                text = nativeAd.body
                visibility = if (nativeAd.body?.isNotEmpty() == true) View.VISIBLE else View.INVISIBLE
            }
            this.bodyView = bodyView

            setNativeAd(nativeAd)
        }

        return nativeAdView
    }
}