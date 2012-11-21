package statm.dev.mapeditor.dom.objects
{
	import statm.dev.mapeditor.app.MapEditingActions;
	import statm.dev.mapeditor.dom.DomNode;
	import statm.dev.mapeditor.dom.Map;
	import statm.dev.mapeditor.dom.item.MobItemDefinition;

	/**
	 * DOM 对象：怪物。
	 *
	 * @author statm
	 *
	 */
	public class Mob extends Item
	{
		public function Mob(root:DomNode, mobDef:MobItemDefinition = null)
		{
			super(root);
			_name = "怪物";
			_mobDef = mobDef;
		}

		private var _mobDef:MobItemDefinition;

		public function get mobDef():MobItemDefinition
		{
			return _mobDef;
		}

		public function set mobDef(value:MobItemDefinition):void
		{
			_mobDef = value;
		}

		private var _delay:int = 1000;

		public function get delay():int
		{
			return _delay;
		}

		public function set delay(value:int):void
		{
			if (value != _delay)
			{
				_delay = value;
				this.notifyChange(MapEditingActions.OBJECT_PROPS);
			}
		}

		private var _battleEnabled:Boolean = false;

		public function get battleEnabled():Boolean
		{
			return _battleEnabled;
		}

		public function set battleEnabled(value:Boolean):void
		{
			if (value != _battleEnabled)
			{
				_battleEnabled = value;
				this.notifyChange(MapEditingActions.OBJECT_PROPS);
			}
		}

		private var _autoBattle:Boolean = false;

		public function get autoBattle():Boolean
		{
			return _autoBattle;
		}

		public function set autoBattle(value:Boolean):void
		{
			if (value != _autoBattle)
			{
				_autoBattle = value;
				this.notifyChange(MapEditingActions.OBJECT_PROPS);
			}
		}

		private var _autoMove:Boolean = true;

		public function get autoMove():Boolean
		{
			return _autoMove;
		}

		public function set autoMove(value:Boolean):void
		{
			if (value != _autoMove)
			{
				_autoMove = value;
				this.notifyChange(MapEditingActions.OBJECT_PROPS);
			}
		}

		private var _respawnTme:int = 10000;

		public function get respawnTime():int
		{
			return _respawnTme;
		}

		public function set respawnTime(value:int):void
		{
			if (value != _respawnTme)
			{
				_respawnTme = value;
				this.notifyChange(MapEditingActions.OBJECT_PROPS);
			}
		}

		private var _standByTime:int = 10;

		public function get standByTime():int
		{
			return _standByTime;
		}

		public function set standByTime(value:int):void
		{
			if (value != _standByTime)
			{
				_standByTime = value;
				this.notifyChange(MapEditingActions.OBJECT_PROPS);
			}
		}

		private var _moveSpeed:int = 30;

		public function get moveSpeed():int
		{
			return _moveSpeed;
		}

		public function set moveSpeed(value:int):void
		{
			if (value != _moveSpeed)
			{
				_moveSpeed = value;
				this.notifyChange(MapEditingActions.OBJECT_PROPS);
			}
		}

		override public function readXML(xml:XML):void
		{
			this.x = xml.@x;
			this.y = xml.@y;
			this.delay = xml.@delay;
			this.battleEnabled = xml.@battleEnabled;
			this.autoBattle = xml.@autoBattle;
			this.autoMove = xml.@autoMove;
			this.respawnTime = xml.@respawnTime;
			this.standByTime = xml.@standByTime;
			this.moveSpeed = xml.@moveSpeed;

			_mobDef = Map(root).itemDefinitionList.getMobDefinitionByID(parseInt(xml.@mobID));
		}

		override public function toXML():XML
		{
			return <mob x={x} y={y} mobID={_mobDef.mobID} delay={_delay} battleEnabled={_battleEnabled} autoBattle={_autoBattle} autoMove={_autoMove} respawnTime={_respawnTme} standByTime={_standByTime} moveSpeed={_moveSpeed}/>
		}
	}
}
