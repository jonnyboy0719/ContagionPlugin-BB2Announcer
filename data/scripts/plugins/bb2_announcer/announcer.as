namespace BB2
{
	class CGameAnnouncerItem
	{
		string m_Sound;
		AnnouncerTypes m_Type;
		CGameAnnouncerItem(const string &in szSoundEvent, const AnnouncerTypes &in eType)
		{
			m_Sound = szSoundEvent;
			m_Type = eType;
			pGameAnnouncer.AddToList( this );
		}
	}

	//------------------------------------------------------------------------------------------------------------------------//

	class CGameAnnouncerPlayer
	{
		int m_PlayerIndex;
		int m_KillCount;
		float flLastPlayedSound;
		CGameAnnouncerPlayer(const int &in iPlayer)
		{
			m_PlayerIndex = iPlayer;
			m_KillCount = 0;
			flLastPlayedSound = 0.0f;
			pGameAnnouncer.AddToPlayerList( this );
		}

		void PlayEvent( CTerrorPlayer@ pPlayer, const AnnouncerTypes &in eType )
		{
			float fltimeleft = flLastPlayedSound - Globals.GetCurrentTime();
			if ( fltimeleft > 0 ) return;
			flLastPlayedSound = Globals.GetCurrentTime() + 1.5f;
			pGameAnnouncer.PlayEvent( pPlayer, eType );
		}
	}

	//------------------------------------------------------------------------------------------------------------------------//

	class CGameAnnouncer
	{
		private bool bFirstBlood = false;
		private array<CGameAnnouncerItem@> s_Announcer;
		private array<CGameAnnouncerPlayer@> s_PlayerList;
		private int HITGROUP_HEAD = 1;

		void Reset()
		{
			bFirstBlood = false;
			s_Announcer.removeRange( 0, s_Announcer.length() );
			s_PlayerList.removeRange( 0, s_PlayerList.length() );
		}

		void AddToList( CGameAnnouncerItem @item ) { s_Announcer.insertLast( item ); }
		void AddToPlayerList( CGameAnnouncerPlayer @item ) { s_PlayerList.insertLast( item ); }

		void PlayEvent( const AnnouncerTypes &in eType )
		{
			for ( uint i = 0; i < s_Announcer.length(); i++ )
			{
				CGameAnnouncerItem @item = s_Announcer[i];
				if ( eType != item.m_Type ) continue;
				array<int> collector = Utils.CollectPlayers();
				if ( collector.length() > 0 )
				{
					// Go trough our collector
					CTerrorPlayer@ pTerror = null;
					for ( uint u = 0; u < collector.length(); u++ )
					{
						@pTerror = ToTerrorPlayer( collector[ u ] );
						pTerror.PlayWwiseSound( item.m_Sound, "", -1 );
					}
				}
				break;
			}
		}

		void PlayEvent( CTerrorPlayer@ pPlayer, const AnnouncerTypes &in eType )
		{
			for ( uint i = 0; i < s_Announcer.length(); i++ )
			{
				CGameAnnouncerItem @item = s_Announcer[i];
				if ( eType != item.m_Type ) continue;
				pPlayer.PlayWwiseSound( item.m_Sound, "", -1 );
			}
		}

		void Remove( CTerrorPlayer@ pPlayer )
		{
			int client = pPlayer.entindex();
			for ( uint i = 0; i < s_PlayerList.length(); i++ )
			{
				CGameAnnouncerPlayer @item = s_PlayerList[i];
				if ( client == item.m_PlayerIndex )
				{
					s_PlayerList.removeAt( i );
					return;
				}
			}
		}

		void AddIfNotExist( CTerrorPlayer@ pPlayer )
		{
			int client = pPlayer.entindex();
			for ( uint i = 0; i < s_PlayerList.length(); i++ )
			{
				CGameAnnouncerPlayer @item = s_PlayerList[i];
				if ( client == item.m_PlayerIndex ) return;
			}
			CGameAnnouncerPlayer( client );
		}

		void ClearData( CTerrorPlayer@ pPlayer )
		{
			int client = pPlayer.entindex();
			for ( uint i = 0; i < s_PlayerList.length(); i++ )
			{
				CGameAnnouncerPlayer @item = s_PlayerList[i];
				if ( client == item.m_PlayerIndex )
				{
					item.m_KillCount = 0;
					return;
				}
			}
		}

		void Increase( CTerrorPlayer@ pPlayer, const int &in iLastHitgroup, CTakeDamageInfo &in info )
		{
			// Create if we don't exist.
			AddIfNotExist( pPlayer );

			int client = pPlayer.entindex();
			for ( uint i = 0; i < s_PlayerList.length(); i++ )
			{
				CGameAnnouncerPlayer @item = s_PlayerList[i];
				if ( client == item.m_PlayerIndex )
				{
					item.m_KillCount++;
					if ( !bFirstBlood )
					{
						bFirstBlood = true;
						PlayEvent( k_eFirstBlood );
						return;
					}

					if ( (info.GetDamageType() & DMG_BLAST) > 0 )
						item.PlayEvent( pPlayer, k_eFatalDeath );
					else
					{
						bool bCanPlayHS = true;
						switch( item.m_KillCount )
						{
							case 2: item.PlayEvent( pPlayer, k_eMultiKill ); bCanPlayHS = false; break;
							case 3: item.PlayEvent( pPlayer, k_eTripleKill ); bCanPlayHS = false; break;
							case 6: item.PlayEvent( pPlayer, k_eDomination ); bCanPlayHS = false; break;
							case 9: item.PlayEvent( pPlayer, k_eKillingSpree ); bCanPlayHS = false; break;
							case 12: item.PlayEvent( pPlayer, k_eMassacre ); bCanPlayHS = false; break;
							case 15: item.PlayEvent( pPlayer, k_eSlaughter ); bCanPlayHS = false; break;
							case 20: item.PlayEvent( pPlayer, k_eMassSlaughter ); bCanPlayHS = false; break;
						}

						if ( bCanPlayHS )
						{
							if ( iLastHitgroup == HITGROUP_HEAD )
							{
								if ( (info.GetDamageType() & DMG_BULLET) > 0 )
									item.PlayEvent( pPlayer, k_eHeadshot );
								else
									item.PlayEvent( pPlayer, k_eHeadhunter );
							}
						}
					}
					return;
				}
			}
		}
	}

	namespace Announcer
	{
		void Init()
		{
			CGameAnnouncerItem( "BB2_Announcer_FirstBlood", k_eFirstBlood );
			CGameAnnouncerItem( "BB2_Announcer_FatalDeath", k_eFatalDeath );
			CGameAnnouncerItem( "BB2_Announcer_MultiKill", k_eMultiKill );
			CGameAnnouncerItem( "BB2_Announcer_TripleKill", k_eTripleKill );
			CGameAnnouncerItem( "BB2_Announcer_Domination", k_eDomination );
			CGameAnnouncerItem( "BB2_Announcer_KillingSpree", k_eKillingSpree );
			CGameAnnouncerItem( "BB2_Announcer_Massacre", k_eMassacre );
			CGameAnnouncerItem( "BB2_Announcer_Slaughter", k_eSlaughter );
			CGameAnnouncerItem( "BB2_Announcer_MassSlaughter", k_eMassSlaughter );
			CGameAnnouncerItem( "BB2_Announcer_Headshot", k_eHeadshot );
			CGameAnnouncerItem( "BB2_Announcer_Headhunter", k_eHeadhunter );
			CGameAnnouncerItem( "BB2_Announcer_Suicide", k_eSuicide );
			CGameAnnouncerItem( "BB2_Announcer_Countdown5Min", k_eCountdown5Min );
			CGameAnnouncerItem( "BB2_Announcer_Countdown3Min", k_eCountdown3Min );
			CGameAnnouncerItem( "BB2_Announcer_Countdown1Min", k_eCountdown1Min );
			CGameAnnouncerItem( "BB2_Announcer_Countdown30Sec", k_eCountdown30Sec );
			CGameAnnouncerItem( "BB2_Announcer_Countdown10Sec", k_eCountdown10Sec );
			CGameAnnouncerItem( "BB2_Announcer_Countdown5Sec", k_eCountdown5Sec );
			Precache();
		}

		void Precache()
		{
			Engine.PrecacheFile( soundbank, "auto/bb2_announcer.txt" );
			Engine.PrecacheFile( soundbank, "bb2_announcer.bnk" );
		}
	}
}