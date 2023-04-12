namespace BB2
{
	namespace Hooks
	{
		void Init()
		{
			Events::Player::OnPlayerKilled.Hook( @OnPlayerKilled_BB2 );
			Events::Player::OnPlayerConnected.Hook( @OnPlayerConnected_BB2 );
			Events::Player::PlayerSay.Hook( @PlayerSay_BB2 );
		}

		//------------------------------------------------------------------------------------------------------------------------//

		HookReturnCode OnPlayerKilled_BB2( CTerrorPlayer@ pPlayer, CTakeDamageInfo &in DamageInfo )
		{
			if ( pPlayer is null ) return HOOK_CONTINUE;
			pGameAnnouncer.ClearData( pPlayer );
			CTerrorPlayer @pAttacker = ToTerrorPlayer( DamageInfo.GetAttacker() );
			if ( pAttacker is null )
			{
				// If killed by fall damage
				if ( (DamageInfo.GetDamageType() & DMG_FALL) > 0 )
					pGameAnnouncer.PlayEvent( pAttacker, k_eSuicide );
				return HOOK_CONTINUE;
			}
			if ( pPlayer.entindex() == pAttacker.entindex() )
				pGameAnnouncer.PlayEvent( pAttacker, k_eSuicide );
			else
				pGameAnnouncer.Increase( pAttacker, pPlayer.LastHitGroup(), DamageInfo );
			return HOOK_CONTINUE;
		}

		//------------------------------------------------------------------------------------------------------------------------//

		HookReturnCode OnPlayerConnected_BB2( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return HOOK_CONTINUE;
			pGameAnnouncer.ClearData( pPlayer );
			return HOOK_CONTINUE;
		}

		//------------------------------------------------------------------------------------------------------------------------//

		HookReturnCode PlayerSay_BB2( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
		{
			string arg1 = pArgs.Arg( 1 );
			if ( Utils.StrEql( arg1, "timeleft" ) )
			{
				int seconds, hours, minutes;
				seconds = BB2::TimeLeft();
				minutes = seconds / 60;
				hours = minutes / 60;

				string remaining_time = "{chartreuse}00{white}:{chartreuse}00";
				if ( hours > 0 )
					remaining_time = "{chartreuse}" + formatInt( hours, '0', 1 ) + "{white}:{chartreuse}" + formatInt( int(minutes%60), '0', 2 ) + "{white}:{chartreuse}" + int(seconds%60);
				else
					remaining_time = "{chartreuse}" + formatInt( int(minutes%60), '0', 2 ) + "{white}:{chartreuse}" + formatInt( int(seconds%60), '0', 2 );
				Chat.PrintToChat( all, "Timeleft: " + remaining_time );
				return HOOK_HANDLED;
			}
			return HOOK_CONTINUE;
		}
	}
}