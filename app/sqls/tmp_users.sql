create table kouhou.tmp_users (
       id                 int  auto_increment not null,
       uuid               char(36)            not null,
       passcode_hash      varchar(512)        not null,
       access_key         varchar(512)        not null,
       expire             datetime            not null,
       ena_flg            int                 not null default 1,
       del_flg            int                 not null default 0,
       reg_time           timestamp           not null default current_timestamp,
       upd_time           timestamp           not null default current_timestamp on update current_timestamp,
       primary key(id)
 );
