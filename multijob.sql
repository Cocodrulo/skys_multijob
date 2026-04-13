CREATE TABLE `player_multijob` (
	`citizenid` VARCHAR(50) NOT NULL,
	`job` VARCHAR(50) NOT NULL,
	`grade` INT(11) NOT NULL,
	PRIMARY KEY (`citizenid`, `job`) USING BTREE,
	INDEX `job` (`job`) USING BTREE,
	CONSTRAINT `FK_player_multijob_players` FOREIGN KEY (`citizenid`) REFERENCES `players` (`citizenid`) ON UPDATE CASCADE ON DELETE CASCADE
)
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
;
