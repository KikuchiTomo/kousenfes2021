create table kouhou.bingo_game_status(
       id           int auto_increment not null,
       game_id      int                not null,
       status       int                not null default -1,
       turn         int                not null default 0,
       del_flg      int                not null default 0,
       ena_flg      int                not null default 1,
       reg_time     timestamp          not null default current_timestamp, 
       upd_time     timestamp          not null default current_timestamp on update current_timestamp,       
       primary key(id)
);
