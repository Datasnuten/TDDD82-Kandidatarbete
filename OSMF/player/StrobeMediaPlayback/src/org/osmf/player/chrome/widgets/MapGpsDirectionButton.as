package org.osmf.player.chrome.widgets
{
	import flash.events.MouseEvent;
	
	import org.osmf.logging.Log;
	import org.osmf.logging.Logger;
	import org.osmf.net.httpstreaming.HTTPDownloadManager;
	import org.osmf.player.chrome.assets.AssetIDs;
	
	CONFIG::LOGGING
		{
			import org.osmf.logging.Log;
			import org.osmf.logging.Logger;
		}

	public class MapGpsDirectionButton extends ButtonWidget
	{
		private var downManager:HTTPDownloadManager = HTTPDownloadManager.getInstance();
		private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.net.httpstreaming.MapGpsDirectionButton");
		
		public function MapGpsDirectionButton()
		{
			super();
			upFace = AssetIDs.MAP_GPS_DIRECTION_BUTTON_NORMAL
			downFace = AssetIDs.MAP_GPS_DIRECTION_BUTTON_DOWN;
			overFace = AssetIDs.MAP_GPS_DIRECTION_BUTTON_OVER;
		}
	}
}