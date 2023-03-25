namespace BB2
{
	namespace Hooks
	{
		void Init()
		{
			Events::Player::OnPlayerKilled.Hook( @OnPlayerKilled_BB2 );
			Events::Player::OnPlayerConnected.Hook( @OnPlayerConnected_BB2 );
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

	}
}