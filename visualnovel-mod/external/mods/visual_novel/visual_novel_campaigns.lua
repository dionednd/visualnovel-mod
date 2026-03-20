-- Visual Novel System Campaigns

-- visualnovel.registerCampaign(
-- 	"visualnovel/lua/campaign_name.lua", -- starting a new game with the campaign will load this file.
-- 	"Campaign Name",	-- campaign will appear as "Campaign Name"
-- 	"campaign_name", -- save files will be named like "campaign_name_slot1.sav"
-- 	"visualnovel.data.global.safts_completed == true", -- will unlock if visualnovel.data.global.safts_completed is true.
--	false -- if set to true, the engine will default to this campaign if there's no current_campaign.
-- )
-- 


visualnovel.registerCampaign(
	"visualnovel/lua/test/test_ch01.lua", -- lua path (string)
	"Tutorial Campaign", -- campaign name (string)
	"test", -- campaign index name (string) use underscores instead of spaces.
	"true", -- unlock condition (string)
	true -- default campaign (boolean)
)

