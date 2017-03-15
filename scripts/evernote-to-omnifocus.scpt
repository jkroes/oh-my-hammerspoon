FasdUAS 1.101.10   ��   ��    k             l      ��  ��   ��
@author Thanh Pham
@URL www.asianefficiency.com
@lastmod 10 Jun 2012

Imagine you are capturing a lot of notes and you want to later review 
them in Omnifocus? Most of the time you will forget transferring the 
notes into your Omnifocus inbox. This script will help automate this process.

For every note that you want to review, all you have to do is 
tag it with "review" (without quotes) and this script will 
automatically make a new task in your Omnifocus inbox for review 
that links back to your Evernote note.

By default the format of the task is:

"Review: title of your Evernote note" (without the quotes)

Once the task is created, the script will delete the tag from 
the note in Evernote.

REQUIREMENTS:
* Evernote
* Omnifocus

Credit goes to Nick Wild of 360 Degree Media (www.360degreesmedia.com/) 
for the original script. All I have done is modified some bits and pieces, 
but all credit should go to Nick Wild.

If you want to have this script run automatically on a regular interval,
use the program Lingon. Read this blog post on how to do it:

http://www.asianefficiency.com/technology/transfer-evernote-to-omnifocus/

Have fun with the script. If you like it, please leave a comment
on the post mentioned above.

-Thanh Pham
www.asianefficiency.com
     � 	 		� 
 @ a u t h o r   T h a n h   P h a m 
 @ U R L   w w w . a s i a n e f f i c i e n c y . c o m 
 @ l a s t m o d   1 0   J u n   2 0 1 2 
 
 I m a g i n e   y o u   a r e   c a p t u r i n g   a   l o t   o f   n o t e s   a n d   y o u   w a n t   t o   l a t e r   r e v i e w   
 t h e m   i n   O m n i f o c u s ?   M o s t   o f   t h e   t i m e   y o u   w i l l   f o r g e t   t r a n s f e r r i n g   t h e   
 n o t e s   i n t o   y o u r   O m n i f o c u s   i n b o x .   T h i s   s c r i p t   w i l l   h e l p   a u t o m a t e   t h i s   p r o c e s s . 
 
 F o r   e v e r y   n o t e   t h a t   y o u   w a n t   t o   r e v i e w ,   a l l   y o u   h a v e   t o   d o   i s   
 t a g   i t   w i t h   " r e v i e w "   ( w i t h o u t   q u o t e s )   a n d   t h i s   s c r i p t   w i l l   
 a u t o m a t i c a l l y   m a k e   a   n e w   t a s k   i n   y o u r   O m n i f o c u s   i n b o x   f o r   r e v i e w   
 t h a t   l i n k s   b a c k   t o   y o u r   E v e r n o t e   n o t e . 
 
 B y   d e f a u l t   t h e   f o r m a t   o f   t h e   t a s k   i s : 
 
 " R e v i e w :   t i t l e   o f   y o u r   E v e r n o t e   n o t e "   ( w i t h o u t   t h e   q u o t e s ) 
 
 O n c e   t h e   t a s k   i s   c r e a t e d ,   t h e   s c r i p t   w i l l   d e l e t e   t h e   t a g   f r o m   
 t h e   n o t e   i n   E v e r n o t e . 
 
 R E Q U I R E M E N T S : 
 *   E v e r n o t e 
 *   O m n i f o c u s 
 
 C r e d i t   g o e s   t o   N i c k   W i l d   o f   3 6 0   D e g r e e   M e d i a   ( w w w . 3 6 0 d e g r e e s m e d i a . c o m / )   
 f o r   t h e   o r i g i n a l   s c r i p t .   A l l   I   h a v e   d o n e   i s   m o d i f i e d   s o m e   b i t s   a n d   p i e c e s ,   
 b u t   a l l   c r e d i t   s h o u l d   g o   t o   N i c k   W i l d . 
 
 I f   y o u   w a n t   t o   h a v e   t h i s   s c r i p t   r u n   a u t o m a t i c a l l y   o n   a   r e g u l a r   i n t e r v a l , 
 u s e   t h e   p r o g r a m   L i n g o n .   R e a d   t h i s   b l o g   p o s t   o n   h o w   t o   d o   i t : 
 
 h t t p : / / w w w . a s i a n e f f i c i e n c y . c o m / t e c h n o l o g y / t r a n s f e r - e v e r n o t e - t o - o m n i f o c u s / 
 
 H a v e   f u n   w i t h   t h e   s c r i p t .   I f   y o u   l i k e   i t ,   p l e a s e   l e a v e   a   c o m m e n t 
 o n   t h e   p o s t   m e n t i o n e d   a b o v e . 
 
 - T h a n h   P h a m 
 w w w . a s i a n e f f i c i e n c y . c o m 
   
  
 l     ��������  ��  ��        l     ��  ��    I C You can change the variables below to customize it to your liking.     �   �   Y o u   c a n   c h a n g e   t h e   v a r i a b l e s   b e l o w   t o   c u s t o m i z e   i t   t o   y o u r   l i k i n g .      l     ��������  ��  ��        l     ��  ��    % ########## CAN EDIT ###########     �   > # # # # # # # # # #   C A N   E D I T   # # # # # # # # # # #      l     ��������  ��  ��        l     ��  ��    N H the name of the task starts by default with "Review: " (without quotes)     �   �   t h e   n a m e   o f   t h e   t a s k   s t a r t s   b y   d e f a u l t   w i t h   " R e v i e w :   "   ( w i t h o u t   q u o t e s )       l     �� ! "��   ! !  change this to your liking    " � # # 6   c h a n g e   t h i s   t o   y o u r   l i k i n g    $ % $ j     �� &�� 0 
taskprefix 
taskPrefix & m      ' ' � ( (  R e v i e w :   %  ) * ) l     ��������  ��  ��   *  + , + l     �� - .��   - % ########## CAN EDIT ###########    . � / / > # # # # # # # # # #   C A N   E D I T   # # # # # # # # # # # ,  0 1 0 l     ��������  ��  ��   1  2 3 2 l     ��������  ��  ��   3  4 5 4 l     6���� 6 r      7 8 7 l     9���� 9 I    �� :��
�� .sysolocSutxt        TEXT : m      ; ; � < <  C R E A T E D _ L A B E L��  ��  ��   8 o      ����  0 strnotecreated strNoteCreated��  ��   5  = > = l    ?���� ? r     @ A @ l    B���� B I   �� C��
�� .sysolocSutxt        TEXT C m    	 D D � E E " T O D O S _ C R E A T E D _ O N E��  ��  ��   A o      ���� (0 strtodoscreatedone strTodosCreatedOne��  ��   >  F G F l    H���� H r     I J I l    K���� K I   �� L��
�� .sysolocSutxt        TEXT L m     M M � N N $ T O D O S _ C R E A T E D _ M A N Y��  ��  ��   J o      ���� *0 strtodoscreatedmany strTodosCreatedMany��  ��   G  O P O l     ��������  ��  ��   P  Q R Q l    S���� S r     T U T J    ����   U o      ���� 0 thetodolist theTodoList��  ��   R  V W V l     ��������  ��  ��   W  X Y X l  $ Z���� Z Q   $ [ \ ] [ k     ^ ^  _ ` _ l     ��������  ��  ��   `  a b a O     c d c k   $ e e  f g f l   $ $�� h i��   h � � set currentNote to selection	set currentNoteName to (title of item 1 of currentNote)	set currentID to (local id of item 1 of currentNote)     i � j j   s e t   c u r r e n t N o t e   t o   s e l e c t i o n  	 s e t   c u r r e n t N o t e N a m e   t o   ( t i t l e   o f   i t e m   1   o f   c u r r e n t N o t e )  	 s e t   c u r r e n t I D   t o   ( l o c a l   i d   o f   i t e m   1   o f   c u r r e n t N o t e )   g  k l k l  $ $��������  ��  ��   l  m n m r   $ ) o p o n  $ ' q r q 1   % '��
�� 
txdl r 1   $ %��
�� 
ascr p o      ���� "0 saveddelimiters savedDelimiters n  s t s r   * 1 u v u J   * - w w  x�� x m   * + y y � z z  /��   v n      { | { 1   . 0��
�� 
txdl | 1   - .��
�� 
ascr t  } ~ } l  2 2��������  ��  ��   ~   �  l  2 2�� � ���   �   selected notes		    � � � � "   s e l e c t e d   n o t e s 	 	 �  � � � r   2 7 � � � 1   2 5��
�� 
EV15 � o      ���� 0 
foundnotes 
foundNotes �  � � � l  8 8��������  ��  ��   �  ��� � X   8 ��� � � k   J � �  � � � r   J S � � � l  J O ����� � l  J O ����� � n   J O � � � 1   K O��
�� 
EVet � o   J K���� 0 anote aNote��  ��  ��  ��   � o      ���� 0 entitle enTitle �  � � � r   T a � � � b   T ] � � � o   T Y���� 0 
taskprefix 
taskPrefix � o   Y \���� 0 entitle enTitle � o      ���� 0 entitle enTitle �  � � � r   b k � � � l  b g ����� � l  b g ����� � n   b g � � � 2  c g��
�� 
EVtg � o   b c���� 0 anote aNote��  ��  ��  ��   � o      ���� 0 entags enTags �  � � � l  l l�� � ���   � ) #set enId to (the local id of aNote)    � � � � F s e t   e n I d   t o   ( t h e   l o c a l   i d   o f   a N o t e ) �  � � � l  l l�� � ���   � 0 *set enFile to (the last text item of enId)    � � � � T s e t   e n F i l e   t o   ( t h e   l a s t   t e x t   i t e m   o f   e n I d ) �  � � � r   l u � � � n   l q � � � 1   m q��
�� 
EV24 � o   l m���� 0 anote aNote � o      ���� 0 enlink enLink �  � � � r   v � � � � K   v � � � �� � ��� 0 thetitle theTitle � o   y |���� 0 entitle enTitle � �� � ��� 0 thelink   � o    ����� 0 enlink enLink � �� ����� 0 thetags theTags � o   � ����� 0 entags enTags��   � n       � � �  ;   � � � o   � ����� 0 thetodolist theTodoList �  � � � l  � ���������  ��  ��   �  � � � r   � � � � � b   � � � � � o   � ����� 0 
taskprefix 
taskPrefix � o   � ����� 0 entitle enTitle � o      ���� 0 
ennotename   �  � � � r   � � � � � o   � ����� "0 saveddelimiters savedDelimiters � n      � � � 1   � ���
�� 
txdl � 1   � ���
�� 
ascr �  � � � l  � ���������  ��  ��   �  � � � Q   � � � � � k   � � � �  � � � O   � � � � � k   � � � �  � � � r   � � � � � I  � ����� �
�� .corecrel****      � null��   � �� � �
�� 
kocl � m   � ��
� 
FCit � �~ ��}
�~ 
prdt � K   � � � � �| � �
�| 
pnam � l  � � ��{�z � o   � ��y�y 0 entitle enTitle�{  �z   � �x ��w
�x 
FCno � m   � � � � � � �  �w  �}   � o      �v�v 0 newtask   �  � � � l  � ��u�t�s�u  �t  �s   �  ��r � O   � � � � � k   � � � �  � � � l  � ��q � ��q   � B < make new file attachment with properties {file name:enLink}    � � � � x   m a k e   n e w   f i l e   a t t a c h m e n t   w i t h   p r o p e r t i e s   { f i l e   n a m e : e n L i n k } �  � � � r   � � � � � o   � ��p�p 0 enlink enLink � n       � � � 1   � ��o
�o 
FCno � o   � ��n�n 0 newtask   �  � � � l  � ��m � ��m   � * $set note expanded of newtask to true    � � � � H s e t   n o t e   e x p a n d e d   o f   n e w t a s k   t o   t r u e �  �l  l  � ��k�k   
 open    �  o p e n�l   � l  � ��j�i n   � � 1   � ��h
�h 
FCno o   � ��g�g 0 newtask  �j  �i  �r   � n   � � 4  � ��f	
�f 
docu	 m   � ��e�e  m   � �

�                                                                                  OFOC  alis    X  Macintosh HD               ���GH+  �FOmniFocus.app                                                  7?T��Ӷ        ����  	                Applications    ��'      ��Ŧ    �F  (Macintosh HD:Applications: OmniFocus.app    O m n i F o c u s . a p p    M a c i n t o s h   H D  Applications/OmniFocus.app  / ��   � �d l  � ��c�b�a�c  �b  �a  �d   � R      �`�_
�` .ascrerr ****      � **** o      �^�^ 
0 errmsg  �_   � I  ��]
�] .sysodlogaskr        TEXT o   � ��\�\ 
0 errmsg   �[�Z
�[ 
btns J   � �Y m   � � � B O o p s .   D i d   y o u   c r e a t e   t h e   c o n t e x t ?�Y  �Z   � �X l �W�V�U�W  �V  �U  �X  �� 0 anote aNote � o   ; <�T�T 0 
foundnotes 
foundNotes��   d m     !�                                                                                  EVRN  alis    �  Macintosh HD               ���GH+   �Evernote.app                                                   '�Ժ=        ����  	                Applications    ��'      Ժ/     �  �  8Macintosh HD:Users: taazadi1: Applications: Evernote.app    E v e r n o t e . a p p    M a c i n t o s h   H D  (Users/taazadi1/Applications/Evernote.app  /    ��   b �S l �R�Q�P�R  �Q  �P  �S   \ R      �O�N
�O .ascrerr ****      � **** o      �M�M 
0 errmsg  �N   ] I $�L
�L .sysodlogaskr        TEXT o  �K�K 
0 errmsg   �J�I
�J 
btns J    �H m   � b O o p s .   C o u l d n ' t   f i n d   E v e r n o t e !   T r y   c h a n g i n g   p a t h s .�H  �I  ��  ��   Y �G l     �F�E�D�F  �E  �D  �G       �C  '!�C    �B�A�B 0 
taskprefix 
taskPrefix
�A .aevtoappnull  �   � ****! �@"�?�>#$�=
�@ .aevtoappnull  �   � ****" k    $%%  4&&  =''  F((  Q))  X�<�<  �?  �>  # �;�:�; 0 anote aNote�: 
0 errmsg  $ - ;�9�8 D�7 M�6�5�4�3�2 y�1�0�/�.�-�,�+�*�)�(�'�&�%�$�#�"
�!� ��� ��������
�9 .sysolocSutxt        TEXT�8  0 strnotecreated strNoteCreated�7 (0 strtodoscreatedone strTodosCreatedOne�6 *0 strtodoscreatedmany strTodosCreatedMany�5 0 thetodolist theTodoList
�4 
ascr
�3 
txdl�2 "0 saveddelimiters savedDelimiters
�1 
EV15�0 0 
foundnotes 
foundNotes
�/ 
kocl
�. 
cobj
�- .corecnte****       ****
�, 
EVet�+ 0 entitle enTitle
�* 
EVtg�) 0 entags enTags
�( 
EV24�' 0 enlink enLink�& 0 thetitle theTitle�% 0 thelink  �$ 0 thetags theTags�# �" 0 
ennotename  
�! 
docu
�  
FCit
� 
prdt
� 
pnam
� 
FCno� 
� .corecrel****      � null� 0 newtask  � 
0 errmsg  �  
� 
btns
� .sysodlogaskr        TEXT�=%�j E�O�j E�O�j E�OjvE�O �� ���,E�O�kv��,FO*�,E�O ��[�a l kh  �a ,E` Ob   _ %E` O�a -E` O�a ,E` Oa _ a _ a _ a �6FOb   _ %E` O���,FO Na a k/ =*�a a  a !_ a "a #a $a $ %E` &O_ &a ", _ _ &a ",FOPUUOPW X ' (�a )a *kvl +OP[OY�=UOPW X ' (�a )a ,kvl + ascr  ��ޭ