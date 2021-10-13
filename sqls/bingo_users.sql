create table kouhou.bingo_users(
       id           int auto_increment not null,
       uuid         varchar(36)        not null,
       hash         text               not null,
       bingo        text               not null,
       status       int                not null default 0,
       del_flg      int                not null default 0,
       ena_flg      int                not null default 1,
       reg_time     timestamp          not null default current_timestamp, 
       upd_time     timestamp          not null default current_timestamp on update current_timestamp,       
       primary key(id)
);
