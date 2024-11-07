with a_d as 
(
	select
		fabd.ad_date,
		coalesce (fc.campaign_name, 'N/A') as campaign_name,
		coalesce (fa.adset_name, 'N/A') as adset_name,
		coalesce (fabd.url_parameters, 'N/A') as url_parameters,
		coalesce (fabd.spend::numeric, 0) as spend,
		coalesce (fabd.impressions::numeric, 0) as impressions,
		coalesce (fabd.reach::numeric, 0) as reach,
		coalesce (fabd.clicks::numeric, 0) as clicks,
		coalesce (fabd.leads::numeric, 0) as leads,
		coalesce (fabd.value::numeric, 0) as value,
		case when lower (substring(url_parameters, 'utm_campaign=([^$#&]+)'))= 'nan'
			then null
		else lower (substring(url_parameters, 'utm_campaign=([^$#&]+)')) 
			end as utm_campaign
	from
		facebook_ads_basic_daily fabd
	left join facebook_adset fa on
		fa.adset_id = fabd.adset_id
	left join facebook_campaign fc on
		fc.campaign_id = fabd.campaign_id
	union all
		select
				gabd.ad_date,
			coalesce (gabd.campaign_name, 'N/A') as campaign_name,
			coalesce (gabd.adset_name, 'N/A') as adset_name,
			coalesce (gabd.url_parameters, 'N/A') as url_parameters,
			coalesce (gabd.spend, 0) as spend,
			coalesce (gabd.impressions, 0) as impressions,
			coalesce (gabd.reach, 0) as reach,
			coalesce (gabd.clicks, 0) as clicks,
			coalesce (gabd.leads, 0) as leads,
			coalesce (gabd.value, 0) as value,
			case when lower (substring(url_parameters, 'utm_campaign=([^$#&]+)'))= 'nan'
				then null
			else lower (substring(url_parameters, 'utm_campaign=([^$#&]+)')) 
				end as utm_campaign
		from
			google_ads_basic_daily gabd
)
select 
	ad_date,
	utm_campaign,
	sum (spend) as spend,
	sum (impressions) as impressions,
	sum (clicks) as clicks,
	sum (value) as value,
	case when sum (impressions)>0 
		then sum (clicks)/sum (impressions) end as CTR,
	case when sum(clicks)>0 
		then sum(spend)/sum (clicks) end as CPC,
	case when sum (impressions)>0 
		then (sum (spend)/sum (impressions))*1000 end as CPM,
	case when sum (spend)>0 
		then sum (value)/sum (spend)-1 end as ROMI
from a_d
group by a_d.ad_date, utm_campaign
;