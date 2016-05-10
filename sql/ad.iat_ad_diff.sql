create VIEW ad.iat_ad_diff as
--удаленные пользователи
    select '--' a, l b, '-' c from (
    select distinct o.LOGIN_ l from ad.iat_ad_old o
    left join ad.iat_ad_new n on o.LOGIN_ = n.LOGIN_
    where n.LOGIN_ is null) q
    union all
    --удаленные группы
    select '-', o.LOGIN_, o.GROUP_ from ad.iat_ad_old o
    left join ad.iat_ad_new n on o.LOGIN_ = n.LOGIN_ and o.GROUP_ = n.GROUP_
    where n.LOGIN_ is null and o.LOGIN_ in (select distinct LOGIN_ from ad.iat_ad_new) --исключить удаленных пользователей
    union all
    --добавленные группы
    select case when (select 1 from (select distinct n.LOGIN_ ll from ad.iat_ad_new n --если пользователь новый, знаем
    left join ad.iat_ad_old o on o.LOGIN_ = n.LOGIN_
    where o.LOGIN_ is null) q where q.ll = n.LOGIN_) = 1 then '++' else '+' end, n.LOGIN_, n.GROUP_ from ad.iat_ad_new n
    left join ad.iat_ad_old o on o.LOGIN_ = n.LOGIN_ and o.GROUP_ = n.GROUP_
    where o.LOGIN_ is null