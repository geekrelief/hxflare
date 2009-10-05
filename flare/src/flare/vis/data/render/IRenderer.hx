package flare.vis.data.render;

	import flare.vis.data.DataSprite;
	
	/**
	 * Interface for DataSprite rendering modules.
	 */
	interface IRenderer
	{
		/**
		 * Renders drawing content for the input DataSprite.
		 * @param d the DataSprite to draw
		 */
		function render(d:DataSprite):Void;
		
	} // end of interface IRenderer
