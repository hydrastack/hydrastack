SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `cb_author`
-- ----------------------------
DROP TABLE IF EXISTS `cb_author`;
CREATE TABLE `cb_author` (
  `authorID` int(11) NOT NULL auto_increment,
  `firstName` varchar(100) NOT NULL,
  `lastName` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `username` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `isActive` bit(1) NOT NULL default b'0',
  `lastLogin` datetime default NULL,
  `createdDate` datetime NOT NULL,
  `FK_roleID` int(11) NOT NULL,
  PRIMARY KEY  (`authorID`),
  UNIQUE KEY `username` (`username`),
  KEY `FK6847396B9724FA40` (`FK_roleID`),
  KEY `idx_active` (`isActive`),
  KEY `idx_email` (`email`),
  KEY `idx_login` (`username`,`password`,`isActive`),
  CONSTRAINT `FK6847396B9724FA40` FOREIGN KEY (`FK_roleID`) REFERENCES `cb_role` (`roleID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of cb_author
-- ----------------------------
INSERT INTO `cb_author` VALUES ('1', 'HYDRA', 'Stack', 'webmaster@hydrastack.com', 'admin', '8C6976E5B5410415BDE908BD4DEE15DFB167A9C873FC4BB8A81F6F2AB448A918', '', '2012-02-08 16:14:51', '2012-02-03 14:13:38', '2');

-- ----------------------------
-- Table structure for `cb_authorPermissions`
-- ----------------------------
DROP TABLE IF EXISTS `cb_authorPermissions`;
CREATE TABLE `cb_authorPermissions` (
  `FK_authorID` int(11) NOT NULL,
  `FK_permissionID` int(11) NOT NULL,
  KEY `FKE167E219AA6AC0EA` (`FK_authorID`),
  KEY `FKE167E21937C1A3F2` (`FK_permissionID`),
  CONSTRAINT `FKE167E21937C1A3F2` FOREIGN KEY (`FK_permissionID`) REFERENCES `cb_permission` (`permissionID`),
  CONSTRAINT `FKE167E219AA6AC0EA` FOREIGN KEY (`FK_authorID`) REFERENCES `cb_author` (`authorID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of cb_authorPermissions
-- ----------------------------

-- ----------------------------
-- Table structure for `cb_category`
-- ----------------------------
DROP TABLE IF EXISTS `cb_category`;
CREATE TABLE `cb_category` (
  `categoryID` int(11) NOT NULL auto_increment,
  `category` varchar(200) NOT NULL,
  `slug` varchar(200) NOT NULL,
  PRIMARY KEY  (`categoryID`),
  UNIQUE KEY `slug` (`slug`),
  KEY `idx_slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of cb_category
-- ----------------------------
INSERT INTO `cb_category` VALUES ('1', 'News', 'news');
INSERT INTO `cb_category` VALUES ('2', 'ColdFusion', 'coldfusion');
INSERT INTO `cb_category` VALUES ('3', 'ColdBox', 'coldbox');
INSERT INTO `cb_category` VALUES ('4', 'ContentBox', 'contentbox');

-- ----------------------------
-- Table structure for `cb_comment`
-- ----------------------------
DROP TABLE IF EXISTS `cb_comment`;
CREATE TABLE `cb_comment` (
  `commentID` int(11) NOT NULL auto_increment,
  `content` longtext NOT NULL,
  `author` varchar(100) NOT NULL,
  `authorIP` varchar(100) NOT NULL,
  `authorEmail` varchar(255) NOT NULL,
  `authorURL` varchar(255) default NULL,
  `createdDate` datetime NOT NULL,
  `isApproved` bit(1) NOT NULL default b'0',
  `FK_contentID` int(11) NOT NULL,
  PRIMARY KEY  (`commentID`),
  KEY `FKFFCED27F91F58374` (`FK_contentID`),
  KEY `idx_approved` (`isApproved`),
  KEY `idx_contentComment` (`isApproved`,`FK_contentID`),
  KEY `idx_createdDate` (`createdDate`),
  CONSTRAINT `FKFFCED27F91F58374` FOREIGN KEY (`FK_contentID`) REFERENCES `cb_content` (`contentID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of cb_comment
-- ----------------------------
INSERT INTO `cb_comment` VALUES ('1', 'What an amazing blog entry, congratulations!', 'Awesome Joe', '127.0.0.1', 'awesomejoe@gocontentbox.com', 'www.gocontentbox.com/www.gocontentbox.com/www.gocontentbox.com', '2012-02-03 14:13:39', '', '1');
INSERT INTO `cb_comment` VALUES ('2', 'I am some bad words and bad comment not approved', 'Bad Joe', '127.0.0.1', 'badjoe@gocontentbox.com', 'www.gocontentbox.com', '2012-02-03 14:13:39', '', '1');

-- ----------------------------
-- Table structure for `cb_content`
-- ----------------------------
DROP TABLE IF EXISTS `cb_content`;
CREATE TABLE `cb_content` (
  `contentID` int(11) NOT NULL auto_increment,
  `contentType` varchar(255) NOT NULL,
  `title` varchar(200) NOT NULL,
  `slug` varchar(200) NOT NULL,
  `createdDate` datetime NOT NULL,
  `publishedDate` datetime default NULL,
  `isPublished` bit(1) NOT NULL default b'1',
  `allowComments` bit(1) NOT NULL default b'1',
  `passwordProtection` varchar(100) default NULL,
  `HTMLKeywords` varchar(160) default NULL,
  `HTMLDescription` varchar(160) default NULL,
  `hits` bigint(20) default '0',
  `FK_parentID` int(11) default NULL,
  `FK_authorID` int(11) default NULL,
  PRIMARY KEY  (`contentID`),
  UNIQUE KEY `slug` (`slug`),
  KEY `FKFFE01899AA6AC0EA` (`FK_authorID`),
  KEY `FKFFE018996FDC2C99` (`FK_parentID`),
  KEY `idx_slug` (`slug`),
  KEY `idx_discriminator` (`contentType`),
  KEY `idx_publishedSlug` (`slug`,`isPublished`),
  KEY `idx_published` (`contentType`,`isPublished`,`passwordProtection`),
  KEY `idx_createdDate` (`createdDate`),
  KEY `idx_search` (`title`,`isPublished`),
  CONSTRAINT `FKFFE018996FDC2C99` FOREIGN KEY (`FK_parentID`) REFERENCES `cb_content` (`contentID`),
  CONSTRAINT `FKFFE01899AA6AC0EA` FOREIGN KEY (`FK_authorID`) REFERENCES `cb_author` (`authorID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of cb_content
-- ----------------------------
INSERT INTO `cb_content` VALUES ('1', 'Entry', 'My first entry', 'my-first-entry', '2012-02-03 14:13:39', '2012-02-03 14:13:38', '', '', '', 'cool,first entry, contentbox', 'The most amazing ContentBox blog entry in the world', '17', null, null);
INSERT INTO `cb_content` VALUES ('2', 'Page', 'About', 'about', '2012-02-03 14:13:39', '2012-02-03 14:13:00', '', '', '', 'about, contentbox,coldfusion,coldbox', 'The most amazing ContentBox page in the world', '8', null, null);

-- ----------------------------
-- Table structure for `cb_contentversion`
-- ----------------------------
DROP TABLE IF EXISTS `cb_contentversion`;
CREATE TABLE `cb_contentversion` (
  `contentVersionID` int(11) NOT NULL auto_increment,
  `content` longtext NOT NULL,
  `changelog` longtext,
  `version` int(11) NOT NULL,
  `createdDate` datetime NOT NULL,
  `isActive` bit(1) NOT NULL default b'0',
  `FK_authorID` int(11) NOT NULL,
  `FK_contentID` int(11) NOT NULL,
  PRIMARY KEY  (`contentVersionID`),
  KEY `FKE166DFFAA6AC0EA` (`FK_authorID`),
  KEY `FKE166DFF91F58374` (`FK_contentID`),
  KEY `idx_active` (`isActive`),
  KEY `idx_contentVersions` (`isActive`,`FK_contentID`),
  KEY `idx_version` (`version`),
  KEY `idx_createdDate` (`createdDate`),
  CONSTRAINT `FKE166DFF91F58374` FOREIGN KEY (`FK_contentID`) REFERENCES `cb_content` (`contentID`),
  CONSTRAINT `FKE166DFFAA6AC0EA` FOREIGN KEY (`FK_authorID`) REFERENCES `cb_author` (`authorID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of cb_contentversion
-- ----------------------------
INSERT INTO `cb_contentversion` VALUES ('1', 'Hey everybody, this is my first blog entry made from ContentBox.  Isn\'t this amazing!\'', 'Initial creation', '1', '2012-02-03 14:13:39', '', '1', '1');
INSERT INTO `cb_contentversion` VALUES ('2', '<p>Hey welcome to my about page for ContentBox, isn\'t this great!</p><p>{{{CustomHTML slug=\'contentbox\'}}}</p>', 'First creation', '1', '2012-02-03 14:13:39', '', '1', '2');
INSERT INTO `cb_contentversion` VALUES ('3', '<p>\r\n	Hey welcome to my about page for ContentBox, isn&#39;t this great!</p>\r\n<p>\r\n	{{{CustomHTML slug=&#39;contentbox&#39;}}}</p>\r\n', '', '2', '2012-02-06 21:10:48', '', '1', '2');

-- ----------------------------
-- Table structure for `cb_contentVersion`
-- ----------------------------
DROP TABLE IF EXISTS `cb_contentVersion`;
CREATE TABLE `cb_contentVersion` (
  `contentVersionID` int(11) NOT NULL auto_increment,
  `content` longtext NOT NULL,
  `changelog` longtext,
  `version` int(11) NOT NULL,
  `createdDate` datetime NOT NULL,
  `isActive` bit(1) NOT NULL default b'0',
  `FK_authorID` int(11) NOT NULL,
  `FK_contentID` int(11) NOT NULL,
  PRIMARY KEY  (`contentVersionID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of cb_contentVersion
-- ----------------------------

-- ----------------------------
-- Table structure for `cb_customfield`
-- ----------------------------
DROP TABLE IF EXISTS `cb_customfield`;
CREATE TABLE `cb_customfield` (
  `customFieldID` int(11) NOT NULL auto_increment,
  `key` varchar(255) NOT NULL,
  `value` longtext NOT NULL,
  `FK_contentID` int(11) default NULL,
  PRIMARY KEY  (`customFieldID`),
  KEY `FK1844684991F58374` (`FK_contentID`),
  KEY `idx_contentCustomFields` (`FK_contentID`),
  CONSTRAINT `FK1844684991F58374` FOREIGN KEY (`FK_contentID`) REFERENCES `cb_content` (`contentID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of cb_customfield
-- ----------------------------

-- ----------------------------
-- Table structure for `cb_customhtml`
-- ----------------------------
DROP TABLE IF EXISTS `cb_customhtml`;
CREATE TABLE `cb_customhtml` (
  `contentID` int(11) NOT NULL auto_increment,
  `title` varchar(200) NOT NULL,
  `slug` varchar(200) NOT NULL,
  `description` longtext,
  `content` longtext NOT NULL,
  `createdDate` datetime NOT NULL,
  PRIMARY KEY  (`contentID`),
  UNIQUE KEY `slug` (`slug`),
  KEY `idx_customHTML_slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of cb_customhtml
-- ----------------------------
INSERT INTO `cb_customhtml` VALUES ('1', 'ContactInfo', 'contentbox', 'Our contact information', '<p style=\"text-align: center;\">\n	<a href=\"http://gocontentbox.org\"><img alt=\"\" src=\"/modules/contentbox/content/ContentBox_125.gif\" style=\"width: 124px; height: 118px;\" /></a></p>\n<p style=\"text-align: center;\">\n	Created by <a href=\"http://www.ortussolutions.com\">Ortus Solutions, Corp</a> and powered by <a href=\"http://coldbox.org\">ColdBox Platform</a>.</p>', '2012-02-03 14:13:39');

-- ----------------------------
-- Table structure for `cb_customHTML`
-- ----------------------------
DROP TABLE IF EXISTS `cb_customHTML`;
CREATE TABLE `cb_customHTML` (
  `contentID` int(11) NOT NULL auto_increment,
  `title` varchar(200) NOT NULL,
  `slug` varchar(200) NOT NULL,
  `description` longtext,
  `content` longtext NOT NULL,
  `createdDate` datetime NOT NULL,
  PRIMARY KEY  (`contentID`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of cb_customHTML
-- ----------------------------

-- ----------------------------
-- Table structure for `cb_entry`
-- ----------------------------
DROP TABLE IF EXISTS `cb_entry`;
CREATE TABLE `cb_entry` (
  `contentID` int(11) NOT NULL,
  `excerpt` longtext,
  PRIMARY KEY  (`contentID`),
  KEY `FK141674927FFF6A7` (`contentID`),
  CONSTRAINT `FK141674927FFF6A7` FOREIGN KEY (`contentID`) REFERENCES `cb_content` (`contentID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of cb_entry
-- ----------------------------
INSERT INTO `cb_entry` VALUES ('1', '');

-- ----------------------------
-- Table structure for `cb_entryCategories`
-- ----------------------------
DROP TABLE IF EXISTS `cb_entryCategories`;
CREATE TABLE `cb_entryCategories` (
  `FK_contentID` int(11) NOT NULL,
  `FK_categoryID` int(11) NOT NULL,
  KEY `FKC01C884EF10ECD0` (`FK_categoryID`),
  KEY `FKC01C884EFB9F8BAD` (`FK_contentID`),
  CONSTRAINT `FKC01C884EF10ECD0` FOREIGN KEY (`FK_categoryID`) REFERENCES `cb_category` (`categoryID`),
  CONSTRAINT `FKC01C884EFB9F8BAD` FOREIGN KEY (`FK_contentID`) REFERENCES `cb_content` (`contentID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of cb_entryCategories
-- ----------------------------

-- ----------------------------
-- Table structure for `cb_page`
-- ----------------------------
DROP TABLE IF EXISTS `cb_page`;
CREATE TABLE `cb_page` (
  `contentID` int(11) NOT NULL,
  `layout` varchar(200) default NULL,
  `order` int(11) default '0',
  `showInMenu` bit(1) NOT NULL default b'1',
  PRIMARY KEY  (`contentID`),
  KEY `FK21B2F26F9636A2E2` (`contentID`),
  KEY `idx_showInMenu` (`showInMenu`),
  CONSTRAINT `FK21B2F26F9636A2E2` FOREIGN KEY (`contentID`) REFERENCES `cb_content` (`contentID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of cb_page
-- ----------------------------
INSERT INTO `cb_page` VALUES ('2', 'pageNoSidebar', '1', '');

-- ----------------------------
-- Table structure for `cb_permission`
-- ----------------------------
DROP TABLE IF EXISTS `cb_permission`;
CREATE TABLE `cb_permission` (
  `permissionID` int(11) NOT NULL auto_increment,
  `permission` varchar(255) NOT NULL,
  `description` longtext,
  PRIMARY KEY  (`permissionID`),
  UNIQUE KEY `permission` (`permission`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of cb_permission
-- ----------------------------
INSERT INTO `cb_permission` VALUES ('1', 'PAGES_ADMIN', 'Ability to manage content pages, default is view only');
INSERT INTO `cb_permission` VALUES ('2', 'LAYOUT_ADMIN', 'Ability to manage layouts, default is view only');
INSERT INTO `cb_permission` VALUES ('3', 'WIDGET_ADMIN', 'Ability to manage widgets, default is view only');
INSERT INTO `cb_permission` VALUES ('4', 'GLOBALHTML_ADMIN', 'Ability to manage the system\'s global HTML content used on layouts');
INSERT INTO `cb_permission` VALUES ('5', 'TOOLS_IMPORT', 'Ability to import data into ContentBox');
INSERT INTO `cb_permission` VALUES ('6', 'SYSTEM_TAB', 'Access to the ContentBox System tools');
INSERT INTO `cb_permission` VALUES ('7', 'ENTRIES_ADMIN', 'Ability to manage blog entries, default is view only');
INSERT INTO `cb_permission` VALUES ('8', 'CUSTOMHTML_ADMIN', 'Ability to manage custom HTML, default is view only');
INSERT INTO `cb_permission` VALUES ('9', 'VERSIONS_ROLLBACK', 'Ability to rollback content versions');
INSERT INTO `cb_permission` VALUES ('10', 'RELOAD_MODULES', 'Ability to reload modules');
INSERT INTO `cb_permission` VALUES ('11', 'COMMENTS_ADMIN', 'Ability to manage comments, default is view only');
INSERT INTO `cb_permission` VALUES ('12', 'PERMISSIONS_ADMIN', 'Ability to manage permissions, default is view only');
INSERT INTO `cb_permission` VALUES ('13', 'AUTHOR_ADMIN', 'Ability to manage authors, default is view only');
INSERT INTO `cb_permission` VALUES ('14', 'MEDIAMANAGER_ADMIN', 'Ability to manage the system\'s media manager');
INSERT INTO `cb_permission` VALUES ('15', 'ROLES_ADMIN', 'Ability to manage roles, default is view only');
INSERT INTO `cb_permission` VALUES ('16', 'SYSTEM_RAW_SETTINGS', 'Access to the ContentBox raw geek settings panel');
INSERT INTO `cb_permission` VALUES ('17', 'CATEGORIES_ADMIN', 'Ability to manage categories, default is view only');
INSERT INTO `cb_permission` VALUES ('18', 'SYSTEM_SAVE_CONFIGURATION', 'Ability to update global configuration data');
INSERT INTO `cb_permission` VALUES ('19', 'VERSIONS_DELETE', 'Ability to delete past content versions');
INSERT INTO `cb_permission` VALUES ('20', 'EMAIL_TEMPLATE_ADMIN', 'Ability to manage the system\'s email templates');
INSERT INTO `cb_permission` VALUES ('21', 'SECURITYRULES_ADMIN', 'Ability to manage the system\'s security rules, default is view only');

-- ----------------------------
-- Table structure for `cb_role`
-- ----------------------------
DROP TABLE IF EXISTS `cb_role`;
CREATE TABLE `cb_role` (
  `roleID` int(11) NOT NULL auto_increment,
  `role` varchar(255) NOT NULL,
  `description` longtext,
  PRIMARY KEY  (`roleID`),
  UNIQUE KEY `role` (`role`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of cb_role
-- ----------------------------
INSERT INTO `cb_role` VALUES ('1', 'Editor', 'A ContentBox editor');
INSERT INTO `cb_role` VALUES ('2', 'Administrator', 'A ContentBox Administrator');

-- ----------------------------
-- Table structure for `cb_rolePermissions`
-- ----------------------------
DROP TABLE IF EXISTS `cb_rolePermissions`;
CREATE TABLE `cb_rolePermissions` (
  `FK_roleID` int(11) NOT NULL,
  `FK_permissionID` int(11) NOT NULL,
  KEY `FKDCCC1A4E9724FA40` (`FK_roleID`),
  KEY `FKDCCC1A4E37C1A3F2` (`FK_permissionID`),
  CONSTRAINT `FKDCCC1A4E37C1A3F2` FOREIGN KEY (`FK_permissionID`) REFERENCES `cb_permission` (`permissionID`),
  CONSTRAINT `FKDCCC1A4E9724FA40` FOREIGN KEY (`FK_roleID`) REFERENCES `cb_role` (`roleID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of cb_rolePermissions
-- ----------------------------
INSERT INTO `cb_rolePermissions` VALUES ('1', '11');
INSERT INTO `cb_rolePermissions` VALUES ('1', '8');
INSERT INTO `cb_rolePermissions` VALUES ('1', '1');
INSERT INTO `cb_rolePermissions` VALUES ('1', '17');
INSERT INTO `cb_rolePermissions` VALUES ('1', '7');
INSERT INTO `cb_rolePermissions` VALUES ('1', '2');
INSERT INTO `cb_rolePermissions` VALUES ('1', '4');
INSERT INTO `cb_rolePermissions` VALUES ('1', '14');
INSERT INTO `cb_rolePermissions` VALUES ('1', '9');
INSERT INTO `cb_rolePermissions` VALUES ('2', '1');
INSERT INTO `cb_rolePermissions` VALUES ('2', '2');
INSERT INTO `cb_rolePermissions` VALUES ('2', '3');
INSERT INTO `cb_rolePermissions` VALUES ('2', '4');
INSERT INTO `cb_rolePermissions` VALUES ('2', '5');
INSERT INTO `cb_rolePermissions` VALUES ('2', '6');
INSERT INTO `cb_rolePermissions` VALUES ('2', '7');
INSERT INTO `cb_rolePermissions` VALUES ('2', '8');
INSERT INTO `cb_rolePermissions` VALUES ('2', '9');
INSERT INTO `cb_rolePermissions` VALUES ('2', '10');
INSERT INTO `cb_rolePermissions` VALUES ('2', '11');
INSERT INTO `cb_rolePermissions` VALUES ('2', '12');
INSERT INTO `cb_rolePermissions` VALUES ('2', '13');
INSERT INTO `cb_rolePermissions` VALUES ('2', '14');
INSERT INTO `cb_rolePermissions` VALUES ('2', '15');
INSERT INTO `cb_rolePermissions` VALUES ('2', '16');
INSERT INTO `cb_rolePermissions` VALUES ('2', '17');
INSERT INTO `cb_rolePermissions` VALUES ('2', '18');
INSERT INTO `cb_rolePermissions` VALUES ('2', '20');
INSERT INTO `cb_rolePermissions` VALUES ('2', '19');
INSERT INTO `cb_rolePermissions` VALUES ('2', '21');

-- ----------------------------
-- Table structure for `cb_securityRule`
-- ----------------------------
DROP TABLE IF EXISTS `cb_securityRule`;
CREATE TABLE `cb_securityRule` (
  `ruleID` int(11) NOT NULL auto_increment,
  `whitelist` varchar(255) default NULL,
  `securelist` varchar(255) NOT NULL,
  `roles` varchar(255) default NULL,
  `permissions` longtext,
  `redirect` longtext NOT NULL,
  `useSSL` bit(1) default b'0',
  `order` int(11) NOT NULL default '0',
  `match` varchar(50) default NULL,
  PRIMARY KEY  (`ruleID`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of cb_securityRule
-- ----------------------------
INSERT INTO `cb_securityRule` VALUES ('1', '', '^contentbox-admin:mediamanager\\..*', '', 'MEDIAMANAGER_ADMIN', 'cbadmin/security/login', '', '1', 'event');
INSERT INTO `cb_securityRule` VALUES ('2', '', '^contentbox-admin:versions\\.(remove)', '', 'VERSIONS_DELETE', 'cbadmin/security/login', '', '1', 'event');
INSERT INTO `cb_securityRule` VALUES ('3', '', '^contentbox-admin:versions\\.(rollback)', '', 'VERSIONS_ROLLBACK', 'cbadmin/security/login', '', '1', 'event');
INSERT INTO `cb_securityRule` VALUES ('4', '', '^contentbox-admin:emailtemplates\\..*', '', 'EMAIL_TEMPLATE_ADMIN', 'cbadmin/security/login', '', '2', 'event');
INSERT INTO `cb_securityRule` VALUES ('5', '', '^contentbox-admin:widgets\\.(remove|upload|edit|save|create|doCreate)', '', 'WIDGET_ADMIN', 'cbadmin/security/login', '', '2', 'event');
INSERT INTO `cb_securityRule` VALUES ('6', '', '^contentbox-admin:tools\\.(importer|doImport)', '', 'TOOLS_IMPORT', 'cbadmin/security/login', '', '3', 'event');
INSERT INTO `cb_securityRule` VALUES ('7', '', '^contentbox-admin:(settings|permissions|roles|securityRules)\\..*', '', 'SYSTEM_TAB', 'cbadmin/security/login', '', '4', 'event');
INSERT INTO `cb_securityRule` VALUES ('8', '', '^contentbox-admin:settings\\.save', '', 'SYSTEM_SAVE_CONFIGURATION', 'cbadmin/security/login', '', '5', 'event');
INSERT INTO `cb_securityRule` VALUES ('9', '', '^contentbox-admin:settings\\.(raw|saveRaw|flushCache|flushSingletons|mappingDump|viewCached|remove)', '', 'SYSTEM_RAW_SETTINGS', 'cbadmin/security/login', '', '6', 'event');
INSERT INTO `cb_securityRule` VALUES ('10', '', '^contentbox-admin:securityRules\\.(remove|save|changeOrder|apply)', '', 'SECURITYRULES_ADMIN', 'cbadmin/security/login', '', '7', 'event');
INSERT INTO `cb_securityRule` VALUES ('11', '', '^contentbox-admin:roles\\.(remove|removePermission|save|savePermission)', '', 'ROLES_ADMIN', 'cbadmin/security/login', '', '8', 'event');
INSERT INTO `cb_securityRule` VALUES ('12', '', '^contentbox-admin:permissions\\.(remove|save)', '', 'PERMISSIONS_ADMIN', 'cbadmin/security/login', '', '9', 'event');
INSERT INTO `cb_securityRule` VALUES ('13', '', '^contentbox-admin:dashboard\\.reload', '', 'RELOAD_MODULES', 'cbadmin/security/login', '', '10', 'event');
INSERT INTO `cb_securityRule` VALUES ('14', '', '^contentbox-admin:pages\\.(changeOrder|remove|save|editor)', '', 'PAGES_ADMIN', 'cbadmin/security/login', '', '11', 'event');
INSERT INTO `cb_securityRule` VALUES ('15', '', '^contentbox-admin:layouts\\.(remove|upload|rebuildRegistry|activate)', '', 'LAYOUT_ADMIN', 'cbadmin/security/login', '', '12', 'event');
INSERT INTO `cb_securityRule` VALUES ('16', '', '^contentbox-admin:entries\\.(quickPost|remove|save|editor)', '', 'ENTRIES_ADMIN', 'cbadmin/security/login', '', '13', 'event');
INSERT INTO `cb_securityRule` VALUES ('17', '', '^contentbox-admin:customHTML\\.(editor|remove|save)', '', 'CUSTOMHTML_ADMIN', 'cbadmin/security/login', '', '14', 'event');
INSERT INTO `cb_securityRule` VALUES ('18', '', '^contentbox-admin:comments\\.(doStatusUpdate|editor|moderate|remove|save|saveSettings)', '', 'COMMENTS_ADMIN', 'cbadmin/security/login', '', '15', 'event');
INSERT INTO `cb_securityRule` VALUES ('19', '', '^contentbox-admin:categories\\.(remove|save)', '', 'CATEGORIES_ADMIN', 'cbadmin/security/login', '', '16', 'event');
INSERT INTO `cb_securityRule` VALUES ('20', '', '^contentbox-admin:authors\\.(editor|passwordChange|remove|removePermission|save|savePermission)', '', 'AUTHOR_ADMIN', 'cbadmin/security/login', '', '17', 'event');
INSERT INTO `cb_securityRule` VALUES ('21', '^contentbox-admin:security\\.', '^contentbox-admin:.*', '', '', 'cbadmin/security/login', '', '18', 'event');
INSERT INTO `cb_securityRule` VALUES ('22', '', '^contentbox-filebrowser:.*', '', 'MEDIAMANAGER_ADMIN', 'cbadmin/security/login', '', '19', 'event');

-- ----------------------------
-- Table structure for `cb_setting`
-- ----------------------------
DROP TABLE IF EXISTS `cb_setting`;
CREATE TABLE `cb_setting` (
  `settingID` int(11) NOT NULL auto_increment,
  `name` varchar(100) NOT NULL,
  `value` longtext NOT NULL,
  PRIMARY KEY  (`settingID`)
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of cb_setting
-- ----------------------------
INSERT INTO `cb_setting` VALUES ('1', 'cb_html_preCommentForm', '');
INSERT INTO `cb_setting` VALUES ('2', 'cb_comments_moderation_blockedlist', '');
INSERT INTO `cb_setting` VALUES ('3', 'cb_media_createFolders', 'true');
INSERT INTO `cb_setting` VALUES ('4', 'cb_paging_maxrows', '20');
INSERT INTO `cb_setting` VALUES ('5', 'cb_site_name', 'HYDRA Stack Blog');
INSERT INTO `cb_setting` VALUES ('6', 'cb_comments_captcha', 'true');
INSERT INTO `cb_setting` VALUES ('7', 'cb_comments_urltranslations', 'true');
INSERT INTO `cb_setting` VALUES ('8', 'cb_comments_moderation_notify', 'true');
INSERT INTO `cb_setting` VALUES ('9', 'cb_site_tagline', 'Generic Rapid Application Programming Environment');
INSERT INTO `cb_setting` VALUES ('10', 'cb_comments_notify', 'true');
INSERT INTO `cb_setting` VALUES ('11', 'cb_rss_cachingTimeoutIdle', '15');
INSERT INTO `cb_setting` VALUES ('12', 'cb_content_caching', 'true');
INSERT INTO `cb_setting` VALUES ('13', 'cb_media_uploadify_customOptions', '');
INSERT INTO `cb_setting` VALUES ('14', 'cb_dashboard_recentPages', '5');
INSERT INTO `cb_setting` VALUES ('15', 'cb_html_preEntryDisplay', '');
INSERT INTO `cb_setting` VALUES ('16', 'cb_html_afterSideBar', '');
INSERT INTO `cb_setting` VALUES ('17', 'cb_comments_enabled', 'true');
INSERT INTO `cb_setting` VALUES ('18', 'cb_html_postCommentForm', '');
INSERT INTO `cb_setting` VALUES ('19', 'cb_rss_caching', 'true');
INSERT INTO `cb_setting` VALUES ('20', 'cb_paging_maxRSSComments', '10');
INSERT INTO `cb_setting` VALUES ('21', 'cb_media_uplodify_fileDesc', 'All Files');
INSERT INTO `cb_setting` VALUES ('22', 'cb_html_postEntryDisplay', '');
INSERT INTO `cb_setting` VALUES ('23', 'cb_site_description', 'Generic Rapid Application Programming Environment');
INSERT INTO `cb_setting` VALUES ('24', 'cb_paging_maxentries', '10');
INSERT INTO `cb_setting` VALUES ('25', 'cb_media_uploadify_allowMulti', 'true');
INSERT INTO `cb_setting` VALUES ('26', 'cb_html_afterFooter', '');
INSERT INTO `cb_setting` VALUES ('27', 'cb_html_afterBodyStart', '');
INSERT INTO `cb_setting` VALUES ('28', 'cb_site_layout', 'default');
INSERT INTO `cb_setting` VALUES ('29', 'cb_html_postIndexDisplay', '');
INSERT INTO `cb_setting` VALUES ('30', 'cb_html_beforeContent', '');
INSERT INTO `cb_setting` VALUES ('31', 'cb_dashboard_recentComments', '5');
INSERT INTO `cb_setting` VALUES ('32', 'cb_gravatar_display', 'true');
INSERT INTO `cb_setting` VALUES ('33', 'cb_html_prePageDisplay', '');
INSERT INTO `cb_setting` VALUES ('34', 'cb_html_preArchivesDisplay', '');
INSERT INTO `cb_setting` VALUES ('35', 'cb_site_keywords', '');
INSERT INTO `cb_setting` VALUES ('36', 'cb_site_homepage', 'cbBlog');
INSERT INTO `cb_setting` VALUES ('37', 'cb_rss_maxEntries', '10');
INSERT INTO `cb_setting` VALUES ('38', 'cb_comments_maxDisplayChars', '500');
INSERT INTO `cb_setting` VALUES ('39', 'cb_rss_cachingTimeout', '60');
INSERT INTO `cb_setting` VALUES ('40', 'cb_html_beforeSideBar', '');
INSERT INTO `cb_setting` VALUES ('41', 'cb_content_cacheName', 'Template');
INSERT INTO `cb_setting` VALUES ('42', 'cb_html_preIndexDisplay', '');
INSERT INTO `cb_setting` VALUES ('43', 'cb_content_cachingTimeout', '60');
INSERT INTO `cb_setting` VALUES ('44', 'cb_comments_moderation', 'true');
INSERT INTO `cb_setting` VALUES ('45', 'cb_media_uploadify_sizeLimit', '0');
INSERT INTO `cb_setting` VALUES ('46', 'cb_html_beforeHeadEnd', '');
INSERT INTO `cb_setting` VALUES ('47', 'cb_notify_entry', 'true');
INSERT INTO `cb_setting` VALUES ('48', 'cb_html_afterContent', '');
INSERT INTO `cb_setting` VALUES ('49', 'cb_site_email', 'webmaster@hydrastack.com');
INSERT INTO `cb_setting` VALUES ('50', 'cb_media_directoryRoot', '/hydra/sites/blog/ROOT/modules/contentbox/content');
INSERT INTO `cb_setting` VALUES ('51', 'cb_rss_maxComments', '10');
INSERT INTO `cb_setting` VALUES ('52', 'cb_media_acceptMimeTypes', '');
INSERT INTO `cb_setting` VALUES ('53', 'cb_comments_notifyemails', '');
INSERT INTO `cb_setting` VALUES ('54', 'cb_media_allowDownloads', 'true');
INSERT INTO `cb_setting` VALUES ('55', 'cb_media_allowDelete', 'true');
INSERT INTO `cb_setting` VALUES ('56', 'cb_html_postArchivesDisplay', '');
INSERT INTO `cb_setting` VALUES ('57', 'cb_dashboard_recentEntries', '5');
INSERT INTO `cb_setting` VALUES ('58', 'cb_rss_cacheName', 'Template');
INSERT INTO `cb_setting` VALUES ('59', 'cb_html_beforeBodyEnd', '');
INSERT INTO `cb_setting` VALUES ('60', 'cb_comments_moderation_blacklist', '');
INSERT INTO `cb_setting` VALUES ('61', 'cb_site_outgoingEmail', 'webmaster@hydrastack.com');
INSERT INTO `cb_setting` VALUES ('62', 'cb_media_uplodify_fileExt', '*.*;');
INSERT INTO `cb_setting` VALUES ('63', 'cb_paging_bandgap', '5');
INSERT INTO `cb_setting` VALUES ('64', 'cb_gravatar_rating', 'PG');
INSERT INTO `cb_setting` VALUES ('65', 'cb_html_postPageDisplay', '');
INSERT INTO `cb_setting` VALUES ('66', 'cb_comments_moderation_whitelist', 'true');
INSERT INTO `cb_setting` VALUES ('67', 'cb_notify_page', 'true');
INSERT INTO `cb_setting` VALUES ('68', 'cb_customHTML_caching', 'true');
INSERT INTO `cb_setting` VALUES ('69', 'cb_media_quickViewWidth', '400');
INSERT INTO `cb_setting` VALUES ('70', 'cb_content_cachingTimeoutIdle', '15');
INSERT INTO `cb_setting` VALUES ('71', 'cb_comments_whoisURL', 'http://whois.arin.net/ui/query.do?q');
INSERT INTO `cb_setting` VALUES ('72', 'cb_entry_caching', 'true');
INSERT INTO `cb_setting` VALUES ('73', 'cb_notify_author', 'true');
INSERT INTO `cb_setting` VALUES ('74', 'cb_media_allowUploads', 'true');
INSERT INTO `cb_setting` VALUES ('75', 'cb_active', 'true');
