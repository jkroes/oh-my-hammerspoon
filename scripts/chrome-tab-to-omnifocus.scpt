FasdUAS 1.101.10   ��   ��    k             l      ��  ��   ��
? Veritrope.com
Chrome URLs List to OmniFocus
VERSION 1.1
June 15, 2014

// UPDATE NOTICES
    ** Follow @Veritrope on Twitter, Facebook, Google Plus, and ADN for Update Notices! **

// SUPPORT VERITROPE!
    If this AppleScript was useful to you, please take a second to show your love here: 
    http://veritrope.com/support

// SCRIPT INFORMATION AND UPDATE PAGE
    http://veritrope.com/code/chrome-tab-list-to-omnifocus/

    BASED ON THIS SAFARI/EVERNOTE SCRIPT:
    http://veritrope.com/code/export-all-safari-tabs-to-evernote/

    �AND THIS SAFARI/OMNIFOCUS SCRIPT:
    http://veritrope.com/code/safari-tab-list-to-omnifocus/

    WITH GREAT THANKS TO BRETT TERPSTRA, ZETTT, AND GORDON!

// REQUIREMENTS
    More details on the script information page.

// CHANGELOG
    1.10    FIX FOR DATE STAMP + CHANGE IN OF'S APPLESCRIPT, ADDED NOTIFICATION CENTER, REMOVED LOGGING, ADDED COMMENTS
    1.00    INITIAL RELEASE

// TERMS OF USE:
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

     � 	 		� 
%�   V e r i t r o p e . c o m 
 C h r o m e   U R L s   L i s t   t o   O m n i F o c u s 
 V E R S I O N   1 . 1 
 J u n e   1 5 ,   2 0 1 4 
 
 / /   U P D A T E   N O T I C E S 
         * *   F o l l o w   @ V e r i t r o p e   o n   T w i t t e r ,   F a c e b o o k ,   G o o g l e   P l u s ,   a n d   A D N   f o r   U p d a t e   N o t i c e s !   * * 
 
 / /   S U P P O R T   V E R I T R O P E ! 
         I f   t h i s   A p p l e S c r i p t   w a s   u s e f u l   t o   y o u ,   p l e a s e   t a k e   a   s e c o n d   t o   s h o w   y o u r   l o v e   h e r e :   
         h t t p : / / v e r i t r o p e . c o m / s u p p o r t 
 
 / /   S C R I P T   I N F O R M A T I O N   A N D   U P D A T E   P A G E 
         h t t p : / / v e r i t r o p e . c o m / c o d e / c h r o m e - t a b - l i s t - t o - o m n i f o c u s / 
 
         B A S E D   O N   T H I S   S A F A R I / E V E R N O T E   S C R I P T : 
         h t t p : / / v e r i t r o p e . c o m / c o d e / e x p o r t - a l l - s a f a r i - t a b s - t o - e v e r n o t e / 
 
         & A N D   T H I S   S A F A R I / O M N I F O C U S   S C R I P T : 
         h t t p : / / v e r i t r o p e . c o m / c o d e / s a f a r i - t a b - l i s t - t o - o m n i f o c u s / 
 
         W I T H   G R E A T   T H A N K S   T O   B R E T T   T E R P S T R A ,   Z E T T T ,   A N D   G O R D O N ! 
 
 / /   R E Q U I R E M E N T S 
         M o r e   d e t a i l s   o n   t h e   s c r i p t   i n f o r m a t i o n   p a g e . 
 
 / /   C H A N G E L O G 
         1 . 1 0         F I X   F O R   D A T E   S T A M P   +   C H A N G E   I N   O F ' S   A P P L E S C R I P T ,   A D D E D   N O T I F I C A T I O N   C E N T E R ,   R E M O V E D   L O G G I N G ,   A D D E D   C O M M E N T S 
         1 . 0 0         I N I T I A L   R E L E A S E 
 
 / /   T E R M S   O F   U S E : 
 T h i s   w o r k   i s   l i c e n s e d   u n d e r   t h e   C r e a t i v e   C o m m o n s   A t t r i b u t i o n - N o n C o m m e r c i a l - S h a r e A l i k e   3 . 0   U n p o r t e d   L i c e n s e .   
 T o   v i e w   a   c o p y   o f   t h i s   l i c e n s e ,   v i s i t   h t t p : / / c r e a t i v e c o m m o n s . o r g / l i c e n s e s / b y - n c - s a / 3 . 0 /   o r   s e n d   a   l e t t e r   t o   C r e a t i v e   C o m m o n s ,   4 4 4   C a s t r o   S t r e e t ,   S u i t e   9 0 0 ,   M o u n t a i n   V i e w ,   C a l i f o r n i a ,   9 4 0 4 1 ,   U S A . 
 
   
  
 l     ��������  ��  ��        l      ��  ��    � � 
======================================
// OTHER PROPERTIES (USE CAUTION WHEN CHANGING)
======================================
     �      
 = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
 / /   O T H E R   P R O P E R T I E S   ( U S E   C A U T I O N   W H E N   C H A N G I N G ) 
 = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
      l     ��������  ��  ��        l     ��  ��     RESET     �   
 R E S E T      l     ����  r         J     ����    o      ���� 0 urllist urlList��  ��        l    ����  r       !   m    ����   ! o      ���� 0 
currenttab 
currentTab��  ��     " # " l     ��������  ��  ��   #  $ % $ l      �� & '��   & g a 
======================================
// MAIN PROGRAM 
======================================
    ' � ( ( �   
 = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
 / /   M A I N   P R O G R A M   
 = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
 %  ) * ) l     ��������  ��  ��   *  + , + l     �� - .��   - ( "PROCESSING FRONTMOST CHROME WINDOW    . � / / D P R O C E S S I N G   F R O N T M O S T   C H R O M E   W I N D O W ,  0 1 0 l  	 & 2���� 2 O   	 & 3 4 3 k    % 5 5  6 7 6 r     8 9 8 l    :���� : 4   �� ;
�� 
cwin ; m    ���� ��  ��   9 o      ���� 0 chromewindow chromeWindow 7  < = < r     > ? > n     @ A @ 1    ��
�� 
acTa A o    ���� 0 chromewindow chromeWindow ? o      ���� 0 t   =  B C B l   �� D E��   D  GET TAB INFO    E � F F  G E T   T A B   I N F O C  G H G r     I J I l    K���� K n     L M L 1    ��
�� 
pnam M o    ���� 0 t  ��  ��   J o      ���� 0 tabtitle tabTitle H  N�� N r     % O P O l    # Q���� Q n     # R S R 1   ! #��
�� 
URL  S o     !���� 0 t  ��  ��   P o      ���� 0 taburl tabURL��   4 m   	 
 T T�                                                                                  rimZ  alis    h  Macintosh HD               ���GH+  �FGoogle Chrome.app                                              &p�ӳUv        ����  	                Applications    ��'      ӳ9V    �F  ,Macintosh HD:Applications: Google Chrome.app  $  G o o g l e   C h r o m e . a p p    M a c i n t o s h   H D  Applications/Google Chrome.app  / ��  ��  ��   1  U V U l     ��������  ��  ��   V  W X W l     �� Y Z��   Y " MAKE INBOX ITEM IN OMNIFOCUS    Z � [ [ 8 M A K E   I N B O X   I T E M   I N   O M N I F O C U S X  \ ] \ l  ' K ^���� ^ O   ' K _ ` _ I  . J���� a
�� .corecrel****      � null��   a �� b c
�� 
kocl b m   0 1��
�� 
FCit c �� d��
�� 
prdt d K   2 D e e �� f g
�� 
pnam f l  3 8 h���� h b   3 8 i j i m   3 6 k k � l l  R e v i e w :   j o   6 7���� 0 tabtitle tabTitle��  ��   g �� m��
�� 
FCno m c   ; @ n o n o   ; <���� 0 taburl tabURL o m   < ?��
�� 
ctxt��  ��   ` n   ' + p q p 4  ( +�� r
�� 
docu r m   ) *����  q m   ' ( s s�                                                                                  OFOC  alis    X  Macintosh HD               ���GH+  �FOmniFocus.app                                                  7?T��Ӷ        ����  	                Applications    ��'      ��Ŧ    �F  (Macintosh HD:Applications: OmniFocus.app    O m n i F o c u s . a p p    M a c i n t o s h   H D  Applications/OmniFocus.app  / ��  ��  ��   ]  t u t l     ��������  ��  ��   u  v w v l     �� x y��   x  NOTIFY RESULTS    y � z z  N O T I F Y   R E S U L T S w  { | { l  L R }���� } n  L R ~  ~ I   M R�� ����� *0 notification_center notification_Center �  ��� � o   M N���� 0 tabtitle tabTitle��  ��     f   L M��  ��   |  � � � l     ��������  ��  ��   �  � � � l      �� � ���   � q k 
======================================
// NOTIFICATION SUBROUTINE
======================================
    � � � � �   
 = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
 / /   N O T I F I C A T I O N   S U B R O U T I N E 
 = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
 �  � � � l     ��������  ��  ��   �  � � � l     �� � ���   �  NOTIFICATION CENTER    � � � � & N O T I F I C A T I O N   C E N T E R �  ��� � i      � � � I      �� ����� *0 notification_center notification_Center �  ��� � o      ���� 0 tabtitle tabTitle��  ��   � I    �� � �
�� .sysonotfnull��� ��� TEXT � b      � � � b      � � � m      � � � � � 4 S u c c e s s f u l l y   E x p o r t e d   T a b   � o    ���� 0 tabtitle tabTitle � l 	   ����� � m     � � � � �    t o   O m n i F o c u s��  ��   � �� � �
�� 
appr � m     � � � � � 8 S e n d   C h r o m e   T a b   t o   O m n i F o c u s � �� ���
�� 
subt � m    	 � � � � � %�   V e r i t r o p e . c o m��  ��       
�� � � � ��� � � � ���   � ������������������ *0 notification_center notification_Center
�� .aevtoappnull  �   � ****�� 0 urllist urlList�� 0 
currenttab 
currentTab�� 0 chromewindow chromeWindow�� 0 t  �� 0 tabtitle tabTitle�� 0 taburl tabURL � �� ����� � ����� *0 notification_center notification_Center�� �� ���  �  ���� 0 tabtitle tabTitle��   � ���� 0 tabtitle tabTitle �  � ��� ��� �����
�� 
appr
�� 
subt�� 
�� .sysonotfnull��� ��� TEXT�� �%�%�����  � �� ����� � ���
�� .aevtoappnull  �   � **** � k     R � �   � �   � �  0 � �  \ � �  {����  ��  ��   �   � ���� T��~�}�|�{�z�y�x s�w�v�u�t k�s�r�q�p�o�� 0 urllist urlList�� 0 
currenttab 
currentTab
� 
cwin�~ 0 chromewindow chromeWindow
�} 
acTa�| 0 t  
�{ 
pnam�z 0 tabtitle tabTitle
�y 
URL �x 0 taburl tabURL
�w 
docu
�v 
kocl
�u 
FCit
�t 
prdt
�s 
FCno
�r 
ctxt�q 
�p .corecrel****      � null�o *0 notification_center notification_Center�� SjvE�OjE�O� *�k/E�O��,E�O��,E�O��,E�UO��k/ *����a �%a �a &a a  UO)�k+  � �n�m�n  �m  ��   �  � �  T�l�k�j
�l 
cwin�k�
�j kfrmID   �  � �  ��i�h�g �  T�f�e�d
�f 
cwin�e�
�d kfrmID  
�i 
CrTb�h�
�g kfrmID   � � � � B v R O p s   M P   f o r   P C F   -   S e p t e m b e r   2 0 1 6 � � � � � h t t p s : / / b l u e m e d o r a . c o m / w p - c o n t e n t / u p l o a d s / 2 0 1 6 / 1 0 / v R O p s - M P - f o r - P C F - S e p t e m b e r - 2 0 1 6 . p d f ascr  ��ޭ