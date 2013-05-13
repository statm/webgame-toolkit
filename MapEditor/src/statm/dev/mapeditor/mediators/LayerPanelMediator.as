package statm.dev.mapeditor.mediators
{
    import mx.collections.ArrayCollection;

    import spark.events.IndexChangeEvent;

    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;

    import statm.dev.mapeditor.app.AppNotificationCode;
    import statm.dev.mapeditor.app.AppState;
    import statm.dev.mapeditor.dom.DomNode;
    import statm.dev.mapeditor.dom.Map;
    import statm.dev.mapeditor.dom.layers.MobLayer;
    import statm.dev.mapeditor.dom.layers.RouteLayer;
    import statm.dev.mapeditor.dom.objects.BornPoint;
    import statm.dev.mapeditor.dom.objects.Decoration;
    import statm.dev.mapeditor.dom.objects.LinkDestPoint;
    import statm.dev.mapeditor.dom.objects.LinkPoint;
    import statm.dev.mapeditor.dom.objects.Mark;
    import statm.dev.mapeditor.dom.objects.Mob;
    import statm.dev.mapeditor.dom.objects.RoutePoint;
    import statm.dev.mapeditor.dom.objects.TeleportPoint;
    import statm.dev.mapeditor.modules.LayerPanel;


    /**
     * 工具箱 Mediator。
     *
     * @author statm
     *
     */
    public class LayerPanelMediator extends Mediator
    {
        public static const NAME:String = "LayerPanelMediator";

        private static const EXPANSION_REQUIRING_TYPES:Array = [ TeleportPoint, LinkPoint, BornPoint, LinkDestPoint, MobLayer, Mob, RouteLayer, RoutePoint, Mark, Decoration ];

        public function LayerPanelMediator(mediatorName:String = null, viewComponent:Object = null)
        {
            super(mediatorName, viewComponent);
            viewComponent.layerTree.addEventListener(IndexChangeEvent.CHANGE, tree_changeHandler);
        }

        override public function listNotificationInterests():Array
        {
            return [ AppNotificationCode.MAP_DATA_READY, AppNotificationCode.MAP_FILE_CLOSED, AppNotificationCode.SELECTION_CHANGED ];
        }

        override public function handleNotification(notification:INotification):void
        {
            var map:Map = AppState.getCurrentMap();
            var panel:LayerPanel = LayerPanel(viewComponent);

            switch (notification.getName())
            {
                case AppNotificationCode.MAP_DATA_READY:
                    if (map)
                    {
                        panel.layerTree.dataProvider = new ArrayCollection([ map ]);
                        panel.layerTree.selectedItem = map;
                        panel.layerTree.expandItem(map);

                        panel.layerTree.expandItem(map.grids);
                        panel.layerTree.expandItem(map.items);
                        panel.layerTree.expandItem(map.items.mobLayerContainer);
                    }
                    break;

                case AppNotificationCode.MAP_FILE_CLOSED:
                    panel.layerTree.dataProvider = null;
                    break;

                case AppNotificationCode.SELECTION_CHANGED:
                    var selection:DomNode = AppState.getCurrentSelection();
                    for each (var cls:Class in EXPANSION_REQUIRING_TYPES)
                    {
                        if (selection is cls)
                        {
                            panel.layerTree.expandItem(selection.parent);
                            panel.layerTree.selectedItem = selection;
                        }
                    }
                    break;
            }
        }

        protected function tree_changeHandler(event:IndexChangeEvent):void
        {
            AppState.setCurrentSelection(viewComponent.layerTree.selectedItem);
        }
    }
}
