create table kouhou.locate (
       id                 int  auto_increment not null,
       locate_name        text                not null,
       locate_type        text,
       floor              int,
       locate_id          text, #ruby array
       ena_flg            int                 not null default 1,
       del_flg            int                 not null default 0,
       reg_time           timestamp           not null default current_timestamp,
       upd_time           timestamp           not null default current_timestamp on update current_timestamp,
       primary key(id)
 );
