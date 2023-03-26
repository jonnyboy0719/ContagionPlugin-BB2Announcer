//------------------------------------------------------------------------------------------------------------------------//
#include "hooks.as"
#include "announcer.as"

namespace BB2
{
	enum AnnouncerTypes
	{
		k_eFirstBlood,
		k_eFatalDeath,
		k_eMultiKill,
		k_eTripleKill,
		k_eDomination,
		k_eKillingSpree,
		k_eMassacre,
		k_eSlaughter,
		k_eMassSlaughter,
		k_eHeadshot,
		k_eHeadhunter,
		k_eSuicide,
		k_eCountdown5Min,
		k_eCountdown3Min,
		k_eCountdown1Min,
		k_eCountdown30Sec,
		k_eCountdown10Sec,
		k_eCountdown5Sec
	}

	CGameAnnouncer @pGameAnnouncer = CGameAnnouncer();
	int m_iLastTime = 0;
	float m_flTimeLimit = 0.0f;

	//------------------------------------------------------------------------------------------------------------------------//

	void InitCore()
	{
		BB2::Hooks::Init();
		BB2::Announcer::Init();
		SetupTimeLeft();
	}

	//------------------------------------------------------------------------------------------------------------------------//

	void SetupTimeLeft()
	{
		CASConVarRef @mp_timelimit = ConVar::Find( "mp_timelimit" );
		if ( mp_timelimit is null ) return;
		m_flTimeLimit = (mp_timelimit.GetFloat() * 60);
	}

	//------------------------------------------------------------------------------------------------------------------------//

	void Reset()
	{
		pGameAnnouncer.Reset();
		BB2::Announcer::Init();
		SetupTimeLeft();
	}

	//------------------------------------------------------------------------------------------------------------------------//

	void Think()
	{
		float fltimeleft = m_flTimeLimit - Globals.GetCurrentTime();
		int timeleft = int(fltimeleft);
		if ( timeleft < 0 || ( m_iLastTime == timeleft ) ) return;
		string szMsg = "";
		switch ( timeleft )
		{
			case 300: pGameAnnouncer.PlayEvent( k_eCountdown5Min ); szMsg = "5 Minutes"; break;
			case 180: pGameAnnouncer.PlayEvent( k_eCountdown3Min ); szMsg = "3 Minutes";  break;
			case 60: pGameAnnouncer.PlayEvent( k_eCountdown1Min ); szMsg = "60 Seconds";  break;
			case 30: pGameAnnouncer.PlayEvent( k_eCountdown30Sec ); szMsg = "30 Seconds";  break;
			case 10: pGameAnnouncer.PlayEvent( k_eCountdown10Sec ); szMsg = "10 Seconds";  break;
			case 5: pGameAnnouncer.PlayEvent( k_eCountdown5Sec ); szMsg = "5 Seconds";  break;
			case 0:
			{
				// Empty data
				NetData nData;
				Network::CallFunction( "BB2_OnTimeRanOut", nData );
			}
			break;
		}
		if ( szMsg != "" )
			ThePresident.InfoFeed( szMsg + " remaining...", true ); 
		m_iLastTime = timeleft;
	}

}