#!/usr/bin/env perl
use v5.36;
use utf8;

use Cpanel::JSON::XS qw(decode_json encode_json);

sub items($file = 'items.json') {
    return state $r = do {
        open(my $fh, '<:raw', $file) || die "can't open $file: $!";
        my $items = decode_json(do { local $/; <$fh> });
        close $file;
        $items;
    }
}

sub check($item, $transform) {
    local $_ = fc $item;
    $transform->() if $transform;
    return items->{$_};
}

sub main {
    my $items = items();
    my @rules = (
        undef,
        sub { s{\s* \+ \s* [0-9]+$}{}x },
        sub { s{\s* \: \s* \[[0-9]+\]$}{}x },
        sub { s{s (\s)}{'s$1}x },
        sub { s{s (\s)}{s'$1}x },
        sub { s{\s* \: \s* \[[0-9]+\]$}{s}x },
        sub { s{s (\s)}{'s$1}x; s{\s* \: \s* \[([0-9]+)\]$}{ ($1)}x },
        sub { s{\s* \+ \s* [0-9]+$}{ ashes}x },
        sub { s{^map:\s+(.+)$}{map ($1)}x },
        sub { $_ .= ' ashes' },
        sub { s{^(point forwards|point upwards|point downwards|wait!|calm down!|wave|beckon|casual greeting|warm welcome|bravo!|strength!|jump for joy|triumphant delight|fancy spin|nod in thought|finger snap|rallying cry|heartening cry|bow|polite bow|as you wish|my thanks|curtsy|reverential bow|my lord|what do you want\?|by my sword|hoslows oath|fire spur me|the ring|erudition|prayer|desperate prayer|rapture|inner order|outer order|golden order totality|extreme repentance|grovel for mercy|crossed legs|dozing cross-legged|rest|sitting sideways|dejection|patches crouch|balled up|spread out)$}{gestures} },
        sub {
            state $lookup = {
                'asimi, silver chrysalid' => 'asimi, silver tear',
                'bloody bastard sword' => 'bastard sword',
                'bloody buckler' => 'buckler',
                'bloody highland axe' => 'highland axe',
                'bloody iron roundshield' => 'iron roundshield',
                'bloody lance' => 'lance',
                'bloody longsword' => 'longsword',
                'bloody red thorn roundshield' => 'red thorn roundshield',
                'bloody scimitar' => 'scimitar',
                'bloody twinblade' => 'twinblade',
                'burn, o flame!' => 'burn o flame!',
                'carian knights bloody shield' => 'carian knight\'s shield',
                'erdtree prayerbook' => 'erdtree codex',
                'erdtrees favor +1' => 'erdtree\'s favor',
                'erdtrees favor +2' => 'erdtree\'s favor',
                'flame, cleanse me' => 'flame cleanse me',
                'flame, fall upon them' => 'flame fall upon them',
                'flame, grant me strength' => 'flame grant me strength',
                'flame, protect me' => 'flame protect me',
                'fugitive warriors recipe :[5]' => 'deserter\'s cookbook (2)',
                'gold scarab' => 'golden scarab',
                'golden order principles' => 'golden order principia',
                'great épée' => 'great epee',
                'kalés bell bearing' => 'kale\'s bell bearing',
                'marais executioners sword' => 'marais executioner\'s sword',
                'miséricorde' => 'misericorde',
                'o, flame!' => 'o flame!',
                'prattling pate youre beautiful' => 'prattling pate you\'re beautiful',
                'st. trinas torch' => 'st trina\'s torch',
                'surge, o flame!' => 'surge o flame!',
                'sword of st. trina' => 'sword of st trina',
                'tarnished wizened finger' => 'tarnished\'s wizened finger',
                'terra magicus' => 'terra magica',
                'varrés bouquet' => 'varre\'s bouquet',
                'whirl, o flame!' => 'whirl o flame!',
                'zorayass letter' => 'zorayas\' letter',
            };
            $_ = $lookup->{$_} || ''
        },
    );

    my $mapping = {};
    for my $item (<DATA>) {
        chomp $item;
        my $matched;
        for my $rule (@rules) {
            last if $matched = check($item, $rule);
        }
        if ($matched) {
            $mapping->{$item} = {
                type    => join(' / ', $matched->{type}->@*),
                url     => $matched->{url},
            };
        } else {
            warn "UNMATCHED: $item\n";
        }
    }

    say encode_json($mapping);
    return 0;
}

exit main();

__DATA__
10031128
10083D60
Abandoned Merchants Bell Bearing
Academy Glintstone Key
Academy Glintstone Staff
Academy Magic Pot
Academy Scroll
Acid Spraymist
Adulas Moonblade
Aeonian Butterfly
Agheels Flame
Alabaster Lords Sword
Alberichs Bracers
Alberichs Pointed Hat
Alberichs Pointed Hat (Altered)
Alberichs Robe
Alberichs Robe (Altered)
Alberichs Trousers
Albinauric Ashes
Albinauric Ashes +1
Albinauric Ashes +10
Albinauric Ashes +2
Albinauric Ashes +3
Albinauric Ashes +4
Albinauric Ashes +5
Albinauric Ashes +6
Albinauric Ashes +7
Albinauric Ashes +8
Albinauric Ashes +9
Albinauric Bloodclot
Albinauric Bow
Albinauric Mask
Albinauric Pot
Albinauric Shield
Albinauric Staff
Alexanders Innards
All-Knowing Armor
All-Knowing Armor (Altered)
All-Knowing Gauntlets
All-Knowing Greaves
All-Knowing Helm
Alluring Pot
Altus Bloom
Amber Draught
Amber Starlight
Ambush Shard
Ancestral Follower Ashes
Ancestral Follower Ashes +1
Ancestral Follower Ashes +10
Ancestral Follower Ashes +2
Ancestral Follower Ashes +3
Ancestral Follower Ashes +4
Ancestral Follower Ashes +5
Ancestral Follower Ashes +6
Ancestral Follower Ashes +7
Ancestral Follower Ashes +8
Ancestral Follower Ashes +9
Ancestral Infants Head
Ancestral Spirits Horn
Ancient Death Rancor
Ancient Dragon Apostles Cookbook :[1]
Ancient Dragon Apostles Cookbook :[2]
Ancient Dragon Apostles Cookbook :[3]
Ancient Dragon Apostles Cookbook :[4]
Ancient Dragon Knight Kristoff
Ancient Dragon Knight Kristoff +1
Ancient Dragon Knight Kristoff +10
Ancient Dragon Knight Kristoff +2
Ancient Dragon Knight Kristoff +3
Ancient Dragon Knight Kristoff +4
Ancient Dragon Knight Kristoff +5
Ancient Dragon Knight Kristoff +6
Ancient Dragon Knight Kristoff +7
Ancient Dragon Knight Kristoff +8
Ancient Dragon Knight Kristoff +9
Ancient Dragon Prayerbook
Ancient Dragon Smithing Stone
Ancient Dragonbolt Pot
Ancient Dragons Lightning Spear
Ancient Dragons Lightning Strike
Ants Skull Plate
Antspur Rapier
Arbalest
Archer Ashes
Archer Ashes +1
Archer Ashes +10
Archer Ashes +2
Archer Ashes +3
Archer Ashes +4
Archer Ashes +5
Archer Ashes +6
Archer Ashes +7
Archer Ashes +8
Archer Ashes +9
Aristocrat Boots
Aristocrat Coat
Aristocrat Garb
Aristocrat Garb (Altered)
Aristocrat Hat
Aristocrat Headband
Armorers Cookbook (5)
Armorers Cookbook :[1]
Armorers Cookbook :[2]
Armorers Cookbook :[3]
Armorers Cookbook :[4]
Armorers Cookbook :[5]
Armorers Cookbook :[6]
Armorers Cookbook :[7]
Arrow
Arrows Reach Talisman
Arrows Sting Talisman
Arsenal Charm
Arsenal Charm +1
Arteria Leaf
As You Wish
Ash of War: Assassins Gambit
Ash of War: Barbaric Roar
Ash of War: Barrage
Ash of War: Barricade Shield
Ash of War: Beasts Roar
Ash of War: Black Flame Tornado
Ash of War: Blood Blade
Ash of War: Blood Tax
Ash of War: Bloodhounds Step
Ash of War: Bloody Slash
Ash of War: Braggarts Roar
Ash of War: Carian Grandeur
Ash of War: Carian Greatsword
Ash of War: Carian Retaliation
Ash of War: Charge Forth
Ash of War: Chilling Mist
Ash of War: Cragblade
Ash of War: Determination
Ash of War: Double Slash
Ash of War: Earthshaker
Ash of War: Enchanted Shot
Ash of War: Endure
Ash of War: Eruption
Ash of War: Flame of the Redmanes
Ash of War: Flaming Strike
Ash of War: Giant Hunt
Ash of War: Glintblade Phalanx
Ash of War: Glintstone Pebble
Ash of War: Golden Land
Ash of War: Golden Parry
Ash of War: Golden Slam
Ash of War: Golden Vow
Ash of War: Gravitas
Ash of War: Ground Slam
Ash of War: Hoarah Louxs Earthshaker
Ash of War: Hoarfrost Stomp
Ash of War: Holy Ground
Ash of War: Ice Spear
Ash of War: Impaling Thrust
Ash of War: Kick
Ash of War: Lifesteal Fist
Ash of War: Lightning Ram
Ash of War: Lightning Slash
Ash of War: Lions Claw
Ash of War: Lorettas Slash
Ash of War: Mighty Shot
Ash of War: No Skill
Ash of War: Parry
Ash of War: Phantom Slash
Ash of War: Piercing Fang
Ash of War: Poison Moth Flight
Ash of War: Poisonous Mist
Ash of War: Prayerful Strike
Ash of War: Prelates Charge
Ash of War: Quickstep
Ash of War: Rain of Arrows
Ash of War: Raptor of the Mists
Ash of War: Repeating Thrust
Ash of War: Royal Knights Resolve
Ash of War: Sacred Blade
Ash of War: Sacred Order
Ash of War: Sacred Ring of Light
Ash of War: Seppuku
Ash of War: Shared Order
Ash of War: Shield Bash
Ash of War: Shield Crash
Ash of War: Sky Shot
Ash of War: Spectral Lance
Ash of War: Spinning Slash
Ash of War: Spinning Strikes
Ash of War: Spinning Weapon
Ash of War: Square Off
Ash of War: Stamp (Sweep)
Ash of War: Stamp (Upward Cut)
Ash of War: Storm Assault
Ash of War: Storm Blade
Ash of War: Storm Stomp
Ash of War: Storm Wall
Ash of War: Stormcaller
Ash of War: Sword Dance
Ash of War: Thopss Barrier
Ash of War: Through and Through
Ash of War: Thunderbolt
Ash of War: Trolls Roar
Ash of War: Unsheathe
Ash of War: Vacuum Slice
Ash of War: Vow of the Indomitable
Ash of War: War Cry
Ash of War: Waves of Darkness
Ash of War: White Shadows Lure
Ash of War: Wild Strikes
Ash-of-War Scarab
Asimi, Silver Chrysalid
Asimi, Silver Tear
Asimis Husk
Aspects of the Crucible: Breath
Aspects of the Crucible: Horns
Aspects of the Crucible: Tail
Assassins Approach
Assassins Cerulean Dagger
Assassins Crimson Dagger
Assassins Prayerbook
Astrologer Gloves
Astrologer Hood
Astrologer Robe
Astrologer Robe (Altered)
Astrologer Trousers
Astrologers Staff
Avionette Soldier Ashes
Avionette Soldier Ashes +1
Avionette Soldier Ashes +10
Avionette Soldier Ashes +2
Avionette Soldier Ashes +3
Avionette Soldier Ashes +4
Avionette Soldier Ashes +5
Avionette Soldier Ashes +6
Avionette Soldier Ashes +7
Avionette Soldier Ashes +8
Avionette Soldier Ashes +9
Axe Talisman
Axe of Godfrey
Axe of Godrick
Azula Beastman Ashes
Azula Beastman Ashes +1
Azula Beastman Ashes +10
Azula Beastman Ashes +2
Azula Beastman Ashes +3
Azula Beastman Ashes +4
Azula Beastman Ashes +5
Azula Beastman Ashes +6
Azula Beastman Ashes +7
Azula Beastman Ashes +8
Azula Beastman Ashes +9
Azurs Glintstone Crown
Azurs Glintstone Robe
Azurs Glintstone Staff
Azurs Manchettes
Baldachins Blessing
Balled Up
Ballista Bolt
Bandit Boots
Bandit Garb
Bandit Manchettes
Bandit Mask
Bandits Curved Sword
Banished Knight Armor
Banished Knight Armor (Altered)
Banished Knight Engvall
Banished Knight Engvall +1
Banished Knight Engvall +10
Banished Knight Engvall +2
Banished Knight Engvall +3
Banished Knight Engvall +4
Banished Knight Engvall +5
Banished Knight Engvall +6
Banished Knight Engvall +7
Banished Knight Engvall +8
Banished Knight Engvall +9
Banished Knight Gauntlets
Banished Knight Greaves
Banished Knight Helm
Banished Knight Helm (Altered)
Banished Knight Oleg
Banished Knight Oleg +1
Banished Knight Oleg +10
Banished Knight Oleg +2
Banished Knight Oleg +3
Banished Knight Oleg +4
Banished Knight Oleg +5
Banished Knight Oleg +6
Banished Knight Oleg +7
Banished Knight Oleg +8
Banished Knight Oleg +9
Banished Knights Greatsword
Banished Knights Halberd
Banished Knights Shield
Barrier of Gold
Bastard Sword
Bastards Stars
Battle Axe
Battle Hammer
Battlemage Hugues
Battlemage Hugues +1
Battlemage Hugues +10
Battlemage Hugues +2
Battlemage Hugues +3
Battlemage Hugues +4
Battlemage Hugues +5
Battlemage Hugues +6
Battlemage Hugues +7
Battlemage Hugues +8
Battlemage Hugues +9
Battlemage Legwraps
Battlemage Manchettes
Battlemage Robe
Beast Blood
Beast Champion Armor
Beast Champion Armor (Altered)
Beast Champion Gauntlets
Beast Champion Greaves
Beast Champion Helm
Beast Claw
Beast Crest Heater Shield
Beast Eye
Beast Liver
Beast-Repellent Torch
Beastclaw Greathammer
Beastlure Pot
Beastmans Cleaver
Beastmans Curved Sword
Beastmans Jar-Shield
Beckon
Bernahls Bell Bearing
Bestial Constitution
Bestial Sling
Bestial Vitality
Bewitching Branch
Black Blade
Black Bow
Black Dumpling
Black Flame
Black Flame Blade
Black Flame Ritual
Black Flames Protection
Black Hood
Black Knife
Black Knife Armor
Black Knife Armor (Altered)
Black Knife Gauntlets
Black Knife Greaves
Black Knife Hood
Black Knife Tiche
Black Knife Tiche +1
Black Knife Tiche +10
Black Knife Tiche +2
Black Knife Tiche +3
Black Knife Tiche +4
Black Knife Tiche +5
Black Knife Tiche +6
Black Knife Tiche +7
Black Knife Tiche +8
Black Knife Tiche +9
Black Knifeprint
Black Leather Shield
Black Whetblade
Black Wolf Mask
Black-Key Bolt
Blackflame Monk Amon
Blackflame Monk Amon +1
Blackflame Monk Amon +10
Blackflame Monk Amon +2
Blackflame Monk Amon +3
Blackflame Monk Amon +4
Blackflame Monk Amon +5
Blackflame Monk Amon +6
Blackflame Monk Amon +7
Blackflame Monk Amon +8
Blackflame Monk Amon +9
Blackflame Monk Armor
Blackflame Monk Gauntlets
Blackflame Monk Greaves
Blackflame Monk Hood
Blackguards Bell Bearing
Blackguards Iron Mask
Blade of Calling
Blaidds Armor
Blaidds Armor (Altered)
Blaidds Gauntlets
Blaidds Greaves
Blasphemous Blade
Blasphemous Claw
Blessed Dew Talisman
Blessing of the Erdtree
Blessings Boon
Blood Grease
Blood-Tainted Excrement
Bloodboil Aromatic
Bloodbone Arrow
Bloodbone Arrow (Fletched)
Bloodbone Bolt
Bloodboon
Bloodflame Blade
Bloodflame Talons
Bloodhound Claws
Bloodhound Knight Armor
Bloodhound Knight Armor (Altered)
Bloodhound Knight Floh
Bloodhound Knight Floh +1
Bloodhound Knight Floh +10
Bloodhound Knight Floh +2
Bloodhound Knight Floh +3
Bloodhound Knight Floh +4
Bloodhound Knight Floh +5
Bloodhound Knight Floh +6
Bloodhound Knight Floh +7
Bloodhound Knight Floh +8
Bloodhound Knight Floh +9
Bloodhound Knight Gauntlets
Bloodhound Knight Greaves
Bloodhound Knight Helm
Bloodhounds Fang
Bloodrose
Bloodsoaked Manchettes
Bloodsoaked Mask
Bloodsoaked Tabard
Bloodstained Dagger
Bloody Bastard Sword
Bloody Buckler
Bloody Club
Bloody Finger
Bloody Helice
Bloody Highland Axe
Bloody Iron Roundshield
Bloody Lance
Bloody Large Leather Shield
Bloody Longsword
Bloody Red Thorn Roundshield
Bloody Rickety Shield
Bloody Scimitar
Bloody Spear
Bloody Twinblade
Blue Cipher Ring
Blue Cloth Cowl
Blue Cloth Vest
Blue Crest Heater Shield
Blue Dancer Charm
Blue Festive Garb
Blue Festive Hood
Blue Silver Bracelets
Blue Silver Mail Armor
Blue Silver Mail Armor (Altered)
Blue Silver Mail Hood
Blue Silver Mail Skirt
Blue-Feathered Branchsword
Blue-Gold Kite Shield
Blue-White Wooden Shield
Boiled Crab
Boiled Prawn
Bolt
Bolt of Gransax
Boltdrake Talisman
Boltdrake Talisman +1
Boltdrake Talisman +2
Bone Arrow
Bone Arrow (Fletched)
Bone Ballista Bolt
Bone Bolt
Bone Dart
Bone Great Arrow
Bone Great Arrow (Fletched)
Bone Peddlers Bell Bearing
Borealiss Mist
Bow
Brass Shield
Braves Battlewear
Braves Battlewear (Altered)
Braves Bracer
Braves Cord Circlet
Braves Leather Helm
Braves Legwraps
Bravo!
Briar Armor
Briar Armor (Altered)
Briar Gauntlets
Briar Greatshield
Briar Greaves
Briar Helm
Briars of Punishment
Briars of Sin
Brick Hammer
Broadsword
Buckler
Budding Cave Moss
Budding Horn
Bull-Goat Armor
Bull-Goat Gauntlets
Bull-Goat Greaves
Bull-Goat Helm
Bull-Goats Talisman
Burial Crows Letter
Burn, O Flame!
Burred Bolt
Butchering Knife
By My Sword
Caestus
Calm Down!
Candletree Wooden Shield
Cane Sword
Cannon of Haima
Carian Filigreed Crest
Carian Glintblade Staff
Carian Glintstone Staff
Carian Greatsword
Carian Inverted Statue
Carian Knight Armor
Carian Knight Armor (Altered)
Carian Knight Gauntlets
Carian Knight Greaves
Carian Knight Helm
Carian Knights Bloody Shield
Carian Knights Shield
Carian Knights Sword
Carian Phalanx
Carian Piercer
Carian Regal Scepter
Carian Retaliation
Carian Slicer
Casual Greeting
Catch Flame
Cave Moss
Celebrants Cleaver
Celebrants Rib-Rake
Celebrants Sickle
Celebrants Skull
Celestial Dew
Cerulean Amber Medallion
Cerulean Amber Medallion +1
Cerulean Amber Medallion +2
Cerulean Crystal Tear
Cerulean Hidden Tear
Cerulean Seed Talisman
Cerulean Tear Scarab
Chain Armor
Chain Coif
Chain Gauntlets
Chain Leggings
Chain-Draped Tabard
Chainlink Flail
Champion Bracers
Champion Gaiters
Champion Headband
Champion Pauldron
Champions Song Painting
Chrysalids Memento
Cinquedea
Cipher Pata
Clarifying Boluses
Clarifying Cured Meat
Clarifying Horn Charm
Clarifying Horn Charm +1
Clarifying White Cured Meat
Claw Talisman
Clawmark Seal
Clayman Ashes
Clayman Ashes +1
Clayman Ashes +10
Clayman Ashes +2
Clayman Ashes +3
Clayman Ashes +4
Clayman Ashes +5
Clayman Ashes +6
Clayman Ashes +7
Clayman Ashes +8
Clayman Ashes +9
Claymans Harpoon
Claymore
Cleanrot Armor
Cleanrot Armor (Altered)
Cleanrot Gauntlets
Cleanrot Greaves
Cleanrot Helm
Cleanrot Helm (Altered)
Cleanrot Knight Finlay
Cleanrot Knight Finlay +1
Cleanrot Knight Finlay +10
Cleanrot Knight Finlay +2
Cleanrot Knight Finlay +3
Cleanrot Knight Finlay +4
Cleanrot Knight Finlay +5
Cleanrot Knight Finlay +6
Cleanrot Knight Finlay +7
Cleanrot Knight Finlay +8
Cleanrot Knight Finlay +9
Cleanrot Knights Sword
Cleanrot Spear
Clinging Bone
Cloth Garb
Cloth Trousers
Club
Coded Sword
Coil Shield
Coldbone Arrow
Coldbone Arrow (Fletched)
Coldbone Bolt
Collapsing Stars
Comet
Comet Azur
Commanders Standard
Commoners Garb
Commoners Garb (Altered)
Commoners Headband
Commoners Headband (Altered)
Commoners Shoes
Commoners Simple Garb
Commoners Simple Garb (Altered)
Companion Jar
Composite Bow
Concealing Veil
Confessor Armor
Confessor Armor (Altered)
Confessor Boots
Confessor Gloves
Confessor Hood
Confessor Hood (Altered)
Consorts Mask
Consorts Robe
Consorts Trousers
Conspectus Scroll
Corhyns Bell Bearing
Corhyns Robe
Crab Eggs
Cracked Crystal
Cracked Pot
Crafting Kit
Cranial Vessel Candlestand
Crepuss Black-Key Crossbow
Crepuss Vial
Crescent Moon Axe
Crimson Amber Medallion
Crimson Amber Medallion +1
Crimson Amber Medallion +2
Crimson Bubbletear
Crimson Crystal Tear
Crimson Hood
Crimson Seed Talisman
Crimson Tear Scarab
Crimsonburst Crystal Tear
Crimsonspill Crystal Tear
Crimsonwhorl Bubbletear
Cross-Naginata
Crossed Legs
Crossed-Tree Towershield
Crucible Axe Armor
Crucible Axe Armor (Altered)
Crucible Axe Helm
Crucible Feather Talisman
Crucible Gauntlets
Crucible Greaves
Crucible Hornshield
Crucible Knot Talisman
Crucible Scale Talisman
Crucible Tree Armor
Crucible Tree Armor (Altered)
Crucible Tree Helm
Crystal Barrage
Crystal Bud
Crystal Burst
Crystal Cave Moss
Crystal Dart
Crystal Knife
Crystal Release
Crystal Spear
Crystal Staff
Crystal Sword
Crystal Torrent
Crystalian Ashes
Crystalian Ashes +1
Crystalian Ashes +10
Crystalian Ashes +2
Crystalian Ashes +3
Crystalian Ashes +4
Crystalian Ashes +5
Crystalian Ashes +6
Crystalian Ashes +7
Crystalian Ashes +8
Crystalian Ashes +9
Cuckoo Glintstone
Cuckoo Greatshield
Cuckoo Knight Armor
Cuckoo Knight Armor (Altered)
Cuckoo Knight Gauntlets
Cuckoo Knight Greaves
Cuckoo Knight Helm
Cuckoo Surcoat
Cure Poison
Cursed-Blood Pot
Cursemark of Death
Curtsy
Curved Club
Curved Great Club
Curved Sword Talisman
Daedicars Woe
Dagger
Dagger Talisman
Dancers Castanets
Dappled Cured Meat
Dappled White Cured Meat
Dark Moon Greatsword
Dark Moon Ring
Darkness
Death Lightning
Death Ritual Spear
Deathbed Dress
Deathbed Smalls
Deathroot
Deaths Poker
Deathsbane Jerky
Deathsbane White Jerky
Dectus Medallion (Left)
Dectus Medallion (Right)
Dejection
Demi-Human Ashes
Demi-Human Ashes +1
Demi-Human Ashes +10
Demi-Human Ashes +2
Demi-Human Ashes +3
Demi-Human Ashes +4
Demi-Human Ashes +5
Demi-Human Ashes +6
Demi-Human Ashes +7
Demi-Human Ashes +8
Demi-Human Ashes +9
Demi-Human Queens Staff
Depraved Perfumer Carmaan
Depraved Perfumer Carmaan +1
Depraved Perfumer Carmaan +10
Depraved Perfumer Carmaan +2
Depraved Perfumer Carmaan +3
Depraved Perfumer Carmaan +4
Depraved Perfumer Carmaan +5
Depraved Perfumer Carmaan +6
Depraved Perfumer Carmaan +7
Depraved Perfumer Carmaan +8
Depraved Perfumer Carmaan +9
Depraved Perfumer Gloves
Depraved Perfumer Headscarf
Depraved Perfumer Robe
Depraved Perfumer Robe (Altered)
Depraved Perfumer Trousers
Desperate Prayer
Devourers Scepter
Dexterity-knot Crystal Tear
Dialloss Mask
Diggers Staff
Dirty Chainmail
Discarded Palace Key
Discus of Light
Dismounter
Distinguished Greatshield
Divine Fortification
Dolores the Sleeping Arrow Puppet
Dolores the Sleeping Arrow Puppet +1
Dolores the Sleeping Arrow Puppet +10
Dolores the Sleeping Arrow Puppet +2
Dolores the Sleeping Arrow Puppet +3
Dolores the Sleeping Arrow Puppet +4
Dolores the Sleeping Arrow Puppet +5
Dolores the Sleeping Arrow Puppet +6
Dolores the Sleeping Arrow Puppet +7
Dolores the Sleeping Arrow Puppet +8
Dolores the Sleeping Arrow Puppet +9
Dozing Cross-Legged
Dragon Communion Seal
Dragon Cult Prayerbook
Dragon Greatclaw
Dragon Halberd
Dragon Heart
Dragon Kings Cragblade
Dragon Towershield
Dragonbolt Blessing
Dragonclaw
Dragonclaw Shield
Dragoncrest Greatshield Talisman
Dragoncrest Shield Talisman
Dragoncrest Shield Talisman +1
Dragoncrest Shield Talisman +2
Dragonfire
Dragonice
Dragonmaw
Dragonscale Blade
Dragonwound Grease
Drake Knight Armor
Drake Knight Armor (Altered)
Drake Knight Gauntlets
Drake Knight Greaves
Drake Knight Helm
Drake Knight Helm (Altered)
Drawing-Room Key
Drawstring Blood Grease
Drawstring Fire Grease
Drawstring Freezing Grease
Drawstring Holy Grease
Drawstring Lightning Grease
Drawstring Magic Grease
Drawstring Poison Grease
Drawstring Rot Grease
Drawstring Soporific Grease
Ds Bell Bearing
Duelist Greataxe
Duelist Greaves
Duelist Helm
Duelists Furled Finger
Dung Eater Puppet
Dung Eater Puppet +1
Dung Eater Puppet +10
Dung Eater Puppet +2
Dung Eater Puppet +3
Dung Eater Puppet +4
Dung Eater Puppet +5
Dung Eater Puppet +6
Dung Eater Puppet +7
Dung Eater Puppet +8
Dung Eater Puppet +9
Dwelling Arrow
Eccentrics Armor
Eccentrics Breeches
Eccentrics Hood
Eccentrics Hood (Altered)
Eccentrics Manchettes
Eclipse Crest Greatshield
Eclipse Crest Heater Shield
Eclipse Shotel
Ekzykess Decay
Elden Lord Armor
Elden Lord Armor (Altered)
Elden Lord Bracers
Elden Lord Crown
Elden Lord Greaves
Elden Remembrance
Elden Stars
Electrify Armament
Eleonoras Poleblade
Entwining Umbilical Cord
Envoy Crown
Envoys Greathorn
Envoys Horn
Envoys Long Horn
Erdleaf Flower
Erdsteel Dagger
Erdtree Bow
Erdtree Codex
Erdtree Greatbow
Erdtree Greatshield
Erdtree Heal
Erdtree Prayerbook
Erdtree Seal
Erdtree Surcoat
Erdtrees Favor
Erdtrees Favor +1
Erdtrees Favor +2
Errant Sorcerer Boots
Errant Sorcerer Manchettes
Errant Sorcerer Robe
Errant Sorcerer Robe (Altered)
Erudition
Estoc
Eternal Darkness
Exalted Flesh
Executioners Greataxe
Exile Armor
Exile Gauntlets
Exile Greaves
Exile Hood
Explosive Bolt
Explosive Ghostflame
Explosive Greatbolt
Explosive Stone
Explosive Stone Clump
Extreme Repentance
Eye Surcoat
Eye of Yelough
Faded Erdleaf Flower
Faith-knot Crystal Tear
Faithfuls Canvas Talisman
Falchion
Fallingstar Beast Jaw
Family Heads
Fan Daggers
Fancy Spin
Fanged Imp Ashes
Fanged Imp Ashes +1
Fanged Imp Ashes +10
Fanged Imp Ashes +2
Fanged Imp Ashes +3
Fanged Imp Ashes +4
Fanged Imp Ashes +5
Fanged Imp Ashes +6
Fanged Imp Ashes +7
Fanged Imp Ashes +8
Fanged Imp Ashes +9
Fell Omen Cloak
Festering Bloody Finger
Festive Garb
Festive Garb (Altered)
Festive Hood
Festive Hood (Altered)
Fetid Pot
Fevors Cookbook :[1]
Fevors Cookbook :[2]
Fevors Cookbook :[3]
Fias Hood
Fias Mist
Fias Robe
Fias Robe (Altered)
Finger Maiden Fillet
Finger Maiden Robe
Finger Maiden Robe (Altered)
Finger Maiden Shoes
Finger Maiden Therolina Puppet
Finger Maiden Therolina Puppet +1
Finger Maiden Therolina Puppet +10
Finger Maiden Therolina Puppet +2
Finger Maiden Therolina Puppet +3
Finger Maiden Therolina Puppet +4
Finger Maiden Therolina Puppet +5
Finger Maiden Therolina Puppet +6
Finger Maiden Therolina Puppet +7
Finger Maiden Therolina Puppet +8
Finger Maiden Therolina Puppet +9
Finger Seal
Finger Severer
Finger Snap
Fingerprint Armor
Fingerprint Armor (Altered)
Fingerprint Gauntlets
Fingerprint Grape
Fingerprint Greaves
Fingerprint Helm
Fingerprint Stone Shield
Fingerslayer Blade
Fire Blossom
Fire Grease
Fire Monk Armor
Fire Monk Ashes
Fire Monk Ashes +1
Fire Monk Ashes +10
Fire Monk Ashes +2
Fire Monk Ashes +3
Fire Monk Ashes +4
Fire Monk Ashes +5
Fire Monk Ashes +6
Fire Monk Ashes +7
Fire Monk Ashes +8
Fire Monk Ashes +9
Fire Monk Gauntlets
Fire Monk Greaves
Fire Monk Hood
Fire Monks Prayerbook
Fire Pot
Fire Prelate Armor
Fire Prelate Armor (Altered)
Fire Prelate Gauntlets
Fire Prelate Greaves
Fire Prelate Helm
Fire Scorpion Charm
Fire Spur Me
Firebone Arrow
Firebone Arrow (Fletched)
Firebone Bolt
Fireproof Dried Liver
Fires Deadly Sin
Flail
Flamberge
Flame Crest Wooden Shield
Flame Fortification
Flame Sling
Flame of the Fell God
Flame, Cleanse Me
Flame, Fall Upon Them
Flame, Grant Me Strength
Flame, Protect Me
Flame-Shrouding Cracked Tear
Flamedrake Talisman
Flamedrake Talisman +1
Flamedrake Talisman +2
Flaming Bolt
Flask of Cerulean Tears
Flask of Cerulean Tears +1
Flask of Cerulean Tears +10
Flask of Cerulean Tears +11
Flask of Cerulean Tears +12
Flask of Cerulean Tears +2
Flask of Cerulean Tears +3
Flask of Cerulean Tears +4
Flask of Cerulean Tears +5
Flask of Cerulean Tears +6
Flask of Cerulean Tears +7
Flask of Cerulean Tears +8
Flask of Cerulean Tears +9
Flask of Crimson Tears
Flask of Crimson Tears +1
Flask of Crimson Tears +10
Flask of Crimson Tears +11
Flask of Crimson Tears +12
Flask of Crimson Tears +2
Flask of Crimson Tears +3
Flask of Crimson Tears +4
Flask of Crimson Tears +5
Flask of Crimson Tears +6
Flask of Crimson Tears +7
Flask of Crimson Tears +8
Flask of Crimson Tears +9
Flask of Wondrous Physick
Flight Pinion
Flightless Bird Painting
Flocks Canvas Talisman
Flowing Curved Sword
Foot Soldier Cap
Foot Soldier Gauntlets
Foot Soldier Greaves
Foot Soldier Helm
Foot Soldier Helmet
Foot Soldier Tabard
Forked Greatsword
Forked Hatchet
Formic Rock
Fortissaxs Lightning Spear
Founding Rain of Stars
Four-Toed Fowl Foot
Freezing Grease
Freezing Mist
Freezing Pot
Frenzied Burst
Frenzied Flame Seal
Frenzyflame Stone
Frozen Armament
Frozen Lightning Spear
Frozen Needle
Frozen Raisin
Fugitive Warriors Recipe :[5]
Fulgurbloom
Full Moon Crossbow
Fur Leggings
Fur Raiment
Furlcalling Finger Remedy
Furled Fingers Trick-Mirror
Gargoyles Black Axe
Gargoyles Black Blades
Gargoyles Black Halberd
Gargoyles Blackblade
Gargoyles Great Axe
Gargoyles Greatsword
Gargoyles Halberd
Gargoyles Twinblade
Gavel of Haima
Gelmir Glintstone Staff
Gelmir Knight Armor
Gelmir Knight Armor (Altered)
Gelmir Knight Gauntlets
Gelmir Knight Greaves
Gelmir Knight Helm
Gelmirs Fury
Ghizas Wheel
Ghost Glovewort :[1]
Ghost Glovewort :[2]
Ghost Glovewort :[3]
Ghost Glovewort :[4]
Ghost Glovewort :[5]
Ghost Glovewort :[6]
Ghost Glovewort :[7]
Ghost Glovewort :[8]
Ghost Glovewort :[9]
Ghost-Glovewort Pickers Bell Bearing :[1]
Ghost-Glovewort Pickers Bell Bearing :[2]
Ghost-Glovewort Pickers Bell Bearing :[3]
Ghostflame Torch
Giant Rat Ashes
Giant Rat Ashes +1
Giant Rat Ashes +10
Giant Rat Ashes +2
Giant Rat Ashes +3
Giant Rat Ashes +4
Giant Rat Ashes +5
Giant Rat Ashes +6
Giant Rat Ashes +7
Giant Rat Ashes +8
Giant Rat Ashes +9
Giant-Crusher
Giants Prayerbook
Giants Red Braid
Giants Seal
Giantsflame Fire Pot
Giantsflame Take Thee
Gilded Foot Soldier Cap
Gilded Greatshield
Gilded Iron Shield
Glaive
Glass Shard
Glintblade Phalanx
Glintstone Arc
Glintstone Breath
Glintstone Cometshard
Glintstone Craftsmans Cookbook :[1]
Glintstone Craftsmans Cookbook :[2]
Glintstone Craftsmans Cookbook :[3]
Glintstone Craftsmans Cookbook :[4]
Glintstone Craftsmans Cookbook :[5]
Glintstone Craftsmans Cookbook :[6]
Glintstone Craftsmans Cookbook :[7]
Glintstone Craftsmans Cookbook :[8]
Glintstone Firefly
Glintstone Icecrag
Glintstone Kris
Glintstone Pebble
Glintstone Scarab
Glintstone Scrap
Glintstone Sorcerer Ashes
Glintstone Sorcerer Ashes +1
Glintstone Sorcerer Ashes +10
Glintstone Sorcerer Ashes +2
Glintstone Sorcerer Ashes +3
Glintstone Sorcerer Ashes +4
Glintstone Sorcerer Ashes +5
Glintstone Sorcerer Ashes +6
Glintstone Sorcerer Ashes +7
Glintstone Sorcerer Ashes +8
Glintstone Sorcerer Ashes +9
Glintstone Staff
Glintstone Stars
Glintstone Whetblade
Glovewort Pickers Bell Bearing :[1]
Glovewort Pickers Bell Bearing :[2]
Glovewort Pickers Bell Bearing :[3]
Glowstone
Godfrey Icon
Godrick Knight Armor
Godrick Knight Armor (Altered)
Godrick Knight Gauntlets
Godrick Knight Greaves
Godrick Knight Helm
Godrick Soldier Ashes
Godrick Soldier Ashes +1
Godrick Soldier Ashes +10
Godrick Soldier Ashes +2
Godrick Soldier Ashes +3
Godrick Soldier Ashes +4
Godrick Soldier Ashes +5
Godrick Soldier Ashes +6
Godrick Soldier Ashes +7
Godrick Soldier Ashes +8
Godrick Soldier Ashes +9
Godrick Soldier Gauntlets
Godrick Soldier Greaves
Godrick Soldier Helm
Godricks Great Rune
Godskin Apostle Bracelets
Godskin Apostle Hood
Godskin Apostle Robe
Godskin Apostle Trousers
Godskin Noble Bracelets
Godskin Noble Hood
Godskin Noble Robe
Godskin Noble Trousers
Godskin Peeler
Godskin Prayerbook
Godskin Stitcher
Godskin Swaddling Cloth
Godslayers Greatsword
Godslayers Seal
Gold Bracelets
Gold Firefly
Gold Scarab
Gold Sewing Needle
Gold Waistwrap
Gold-Pickled Fowl Foot
Gold-Tinged Excrement
Golden Arrow
Golden Beast Crest Shield
Golden Bolt
Golden Centipede
Golden Epitaph
Golden Great Arrow
Golden Greatshield
Golden Halberd
Golden Lightning Fortification
Golden Order Greatsword
Golden Order Principia
Golden Order Principles
Golden Order Seal
Golden Order Totality
Golden Prosthetic
Golden Rowa
Golden Rune :[10]
Golden Rune :[11]
Golden Rune :[12]
Golden Rune :[13]
Golden Rune :[1]
Golden Rune :[2]
Golden Rune :[3]
Golden Rune :[4]
Golden Rune :[5]
Golden Rune :[6]
Golden Rune :[7]
Golden Rune :[8]
Golden Rune :[9]
Golden Seed
Golden Sunflower
Golden Tailoring Tools
Golden Vow
Goldmasks Rags
Golem Greatbow
Golems Great Arrow
Golems Halberd
Golems Magic Arrow
Gostocs Bell Bearing
Gowrys Bell Bearing
Grace Mimic
Grafted Blade Greatsword
Grafted Dragon
Grass Hair Ornament
Grave Glovewort :[1]
Grave Glovewort :[2]
Grave Glovewort :[3]
Grave Glovewort :[4]
Grave Glovewort :[5]
Grave Glovewort :[6]
Grave Glovewort :[7]
Grave Glovewort :[8]
Grave Glovewort :[9]
Grave Scythe
Grave Violet
Gravekeeper Cloak
Gravekeeper Cloak (Altered)
Gravel Stone
Gravel Stone Seal
Graven-Mass Talisman
Graven-School Talisman
Gravity Stone Chunk
Gravity Stone Fan
Gravity Stone Peddlers Bell Bearing
Gravity Well
Great Arrow
Great Club
Great Dragonfly Head
Great Ghost Glovewort
Great Glintstone Shard
Great Grave Glovewort
Great Heal
Great Horned Headband
Great Knife
Great Mace
Great Omenkiller Cleaver
Great Oracular Bubble
Great Rune of the Unborn
Great Stars
Great Turtle Shell
Great Épée
Great-Jars Arsenal
Greataxe
Greatblade Phalanx
Greatbow
Greathelm
Greathood
Greathorn Hammer
Greatshield Soldier Ashes
Greatshield Soldier Ashes +1
Greatshield Soldier Ashes +10
Greatshield Soldier Ashes +2
Greatshield Soldier Ashes +3
Greatshield Soldier Ashes +4
Greatshield Soldier Ashes +5
Greatshield Soldier Ashes +6
Greatshield Soldier Ashes +7
Greatshield Soldier Ashes +8
Greatshield Soldier Ashes +9
Greatshield Talisman
Greatsword
Green Turtle Talisman
Greenburst Crystal Tear
Greenspill Crystal Tear
Greyolls Roar
Grossmesser
Grovel For Mercy
Guardian Bracers
Guardian Garb
Guardian Garb (Full Bloom)
Guardian Greaves
Guardian Mask
Guardians Swordspear
Guilty Hood
Gurranqs Beast Claw
Haima Glintstone Crown
Halberd
Haligbone Arrow
Haligbone Arrow (Fletched)
Haligbone Bolt
Haligdrake Talisman
Haligdrake Talisman +1
Haligdrake Talisman +2
Haligtree Crest Greatshield
Haligtree Crest Surcoat
Haligtree Gauntlets
Haligtree Greaves
Haligtree Helm
Haligtree Knight Armor
Haligtree Knight Armor (Altered)
Haligtree Knight Gauntlets
Haligtree Knight Greaves
Haligtree Knight Helm
Haligtree Secret Medallion (Left)
Haligtree Secret Medallion (Right)
Haligtree Soldier Ashes
Haligtree Soldier Ashes +1
Haligtree Soldier Ashes +10
Haligtree Soldier Ashes +2
Haligtree Soldier Ashes +3
Haligtree Soldier Ashes +4
Haligtree Soldier Ashes +5
Haligtree Soldier Ashes +6
Haligtree Soldier Ashes +7
Haligtree Soldier Ashes +8
Haligtree Soldier Ashes +9
Halo Scythe
Hammer
Hammer Talisman
Hand Axe
Hand Ballista
Hand of Malenia
Harp Bow
Hawk Crest Wooden Shield
Heal
Heartening Cry
Heater Shield
Heavy Crossbow
Hefty Beast Bone
Helphens Steeple
Herba
Hermit Merchants Bell Bearing :[1]
Hermit Merchants Bell Bearing :[2]
Hermit Merchants Bell Bearing :[3]
Heros Rune :[1]
Heros Rune :[2]
Heros Rune :[3]
Heros Rune :[4]
Heros Rune :[5]
Hierodas Glintstone Crown
High Page Clothes
High Page Clothes (Altered)
High Page Hood
Highland Axe
Highwayman Cloth Armor
Highwayman Gauntlets
Highwayman Hood
Holy Grease
Holy Water Grease
Holy Water Pot
Holy-Shrouding Cracked Tear
Holyproof Dried Liver
Homing Instinct Painting
Honed Bolt
Hookclaws
Horn Bow
Horse Crest Wooden Shield
Hoslows Armor
Hoslows Armor (Altered)
Hoslows Gauntlets
Hoslows Greaves
Hoslows Helm
Hoslows Oath
Hoslows Petal Whip
Hosts Trick-Mirror
Howl of Shabriri
Human Bone Shard
Ice Crest Shield
Icerind Hatchet
Icon Shield
Ijis Bell Bearing
Ijis Confession
Ijis Mirrorhelm
Imbued Sword Key
Immunizing Cured Meat
Immunizing Horn Charm
Immunizing Horn Charm +1
Immunizing White Cured Meat
Immutable Shield
Imp Head (Cat)
Imp Head (Corpse)
Imp Head (Elder)
Imp Head (Fanged)
Imp Head (Long-Tongued)
Imp Head (Wolf)
Imprisoned Merchants Bell Bearing
Incantation Scarab
Inescapable Frenzy
Inner Order
Inquisitors Girandole
Inseparable Sword
Intelligence-knot Crystal Tear
Inverted Hawk Heater Shield
Inverted Hawk Towershield
Invigorating Cured Meat
Invigorating White Cured Meat
Irinas Letter
Iron Ball
Iron Cleaver
Iron Gauntlets
Iron Greatsword
Iron Helmet
Iron Kasa
Iron Roundshield
Iron Spear
Iron Whetblade
Ironjar Aromatic
Isolated Merchants Bell Bearing :[1]
Isolated Merchants Bell Bearing :[2]
Isolated Merchants Bell Bearing :[3]
Ivory Sickle
Ivory-Draped Tabard
Jar
Jar Cannon
Jarwight Puppet
Jarwight Puppet +1
Jarwight Puppet +10
Jarwight Puppet +2
Jarwight Puppet +3
Jarwight Puppet +4
Jarwight Puppet +5
Jarwight Puppet +6
Jarwight Puppet +7
Jarwight Puppet +8
Jarwight Puppet +9
Jawbone Axe
Jellyfish Shield
Jump for Joy
Juvenile Scholar Cap
Juvenile Scholar Robe
Kaiden Armor
Kaiden Gauntlets
Kaiden Helm
Kaiden Sellsword Ashes
Kaiden Sellsword Ashes +1
Kaiden Sellsword Ashes +10
Kaiden Sellsword Ashes +2
Kaiden Sellsword Ashes +3
Kaiden Sellsword Ashes +4
Kaiden Sellsword Ashes +5
Kaiden Sellsword Ashes +6
Kaiden Sellsword Ashes +7
Kaiden Sellsword Ashes +8
Kaiden Sellsword Ashes +9
Kaiden Trousers
Kalés Bell Bearing
Karolos Glintstone Crown
Katar
Kindred of Rot Ashes
Kindred of Rot Ashes +1
Kindred of Rot Ashes +10
Kindred of Rot Ashes +2
Kindred of Rot Ashes +3
Kindred of Rot Ashes +4
Kindred of Rot Ashes +5
Kindred of Rot Ashes +6
Kindred of Rot Ashes +7
Kindred of Rot Ashes +8
Kindred of Rot Ashes +9
Kindred of Rots Exultation
Kite Shield
Knifeprint Clue
Knight Armor
Knight Gauntlets
Knight Greaves
Knight Helm
Knights Greatsword
Kukri
Lance
Lance Talisman
Land Octopus Ovary
Land Squirt Ashes
Land Squirt Ashes +1
Land Squirt Ashes +10
Land Squirt Ashes +2
Land Squirt Ashes +3
Land Squirt Ashes +4
Land Squirt Ashes +5
Land Squirt Ashes +6
Land Squirt Ashes +7
Land Squirt Ashes +8
Land Squirt Ashes +9
Land of Reeds Armor
Land of Reeds Armor (Altered)
Land of Reeds Gauntlets
Land of Reeds Greaves
Land of Reeds Helm
Lands Between Rune
Lansseaxs Glaive
Lantern
Large Club
Large Glintstone Scrap
Large Leather Shield
Larval Tear
Latenna the Albinauric
Latenna the Albinauric +1
Latenna the Albinauric +10
Latenna the Albinauric +2
Latenna the Albinauric +3
Latenna the Albinauric +4
Latenna the Albinauric +5
Latenna the Albinauric +6
Latenna the Albinauric +7
Latenna the Albinauric +8
Latenna the Albinauric +9
Law of Causality
Law of Regression
Lazuli Glintstone Crown
Lazuli Glintstone Sword
Lazuli Robe
Leaden Hardtear
Leather Armor
Leather Boots
Leather Gloves
Leather Trousers
Leather-Draped Tabard
Letter from Volcano Manor
Letter to Bernahl
Letter to Patches
Leyndell Knight Armor
Leyndell Knight Armor (Altered)
Leyndell Knight Gauntlets
Leyndell Knight Greaves
Leyndell Knight Helm
Leyndell Soldier Ashes
Leyndell Soldier Ashes +1
Leyndell Soldier Ashes +10
Leyndell Soldier Ashes +2
Leyndell Soldier Ashes +3
Leyndell Soldier Ashes +4
Leyndell Soldier Ashes +5
Leyndell Soldier Ashes +6
Leyndell Soldier Ashes +7
Leyndell Soldier Ashes +8
Leyndell Soldier Ashes +9
Leyndell Soldier Gauntlets
Leyndell Soldier Greaves
Leyndell Soldier Helm
Lhutel the Headless
Lhutel the Headless +1
Lhutel the Headless +10
Lhutel the Headless +2
Lhutel the Headless +3
Lhutel the Headless +4
Lhutel the Headless +5
Lhutel the Headless +6
Lhutel the Headless +7
Lhutel the Headless +8
Lhutel the Headless +9
Light Crossbow
Lightning Fortification
Lightning Grease
Lightning Pot
Lightning Scorpion Charm
Lightning Spear
Lightning Strike
Lightning-Shrouding Cracked Tear
Lightningbone Arrow
Lightningbone Arrow (Fletched)
Lightningbone Bolt
Lightningproof Dried Liver
Lion Greatbow
Lionels Armor
Lionels Armor (Altered)
Lionels Gauntlets
Lionels Greaves
Lionels Helm
Litany of Proper Death
Living Jar Shard
Lone Wolf Ashes
Lone Wolf Ashes +1
Lone Wolf Ashes +10
Lone Wolf Ashes +2
Lone Wolf Ashes +3
Lone Wolf Ashes +4
Lone Wolf Ashes +5
Lone Wolf Ashes +6
Lone Wolf Ashes +7
Lone Wolf Ashes +8
Lone Wolf Ashes +9
Longbow
Longhaft Axe
Longsword
Longtail Cat Talisman
Lord of Bloods Exultation
Lord of Bloods Favor
Lord of Bloods Robe
Lord of Bloods Robe (Altered)
Lords Aid
Lords Divine Fortification
Lords Heal
Lords Rune
Lordsworns Bolt
Lordsworns Greatsword
Lordsworns Shield
Lordsworns Straight Sword
Lorettas Greatbow
Lorettas Mastery
Lorettas War Sickle
Lost Ashes of War
Lucent Baldachins Blessing
Lucerne
Lucidity
Lump of Flesh
Lusats Glintstone Crown
Lusats Glintstone Staff
Lusats Manchettes
Lusats Robe
Mace
Mad Pumpkin Head Ashes
Mad Pumpkin Head Ashes +1
Mad Pumpkin Head Ashes +10
Mad Pumpkin Head Ashes +2
Mad Pumpkin Head Ashes +3
Mad Pumpkin Head Ashes +4
Mad Pumpkin Head Ashes +5
Mad Pumpkin Head Ashes +6
Mad Pumpkin Head Ashes +7
Mad Pumpkin Head Ashes +8
Mad Pumpkin Head Ashes +9
Magic Downpour
Magic Fortification
Magic Glintblade
Magic Grease
Magic Pot
Magic Scorpion Charm
Magic-Shrouding Cracked Tear
Magicbone Arrow
Magicbone Arrow (Fletched)
Magicbone Bolt
Magma Blade
Magma Breath
Magma Shot
Magma Whip Candlestick
Magma Wyrms Scalesword
Malenias Armor
Malenias Armor (Altered)
Malenias Gauntlet
Malenias Great Rune
Malenias Greaves
Malenias Winged Helm
Malformed Dragon Armor
Malformed Dragon Gauntlets
Malformed Dragon Greaves
Malformed Dragon Helm
Malikeths Armor
Malikeths Armor (Altered)
Malikeths Black Blade
Malikeths Gauntlets
Malikeths Greaves
Malikeths Helm
Man-Serpent Ashes
Man-Serpent Ashes +1
Man-Serpent Ashes +10
Man-Serpent Ashes +2
Man-Serpent Ashes +3
Man-Serpent Ashes +4
Man-Serpent Ashes +5
Man-Serpent Ashes +6
Man-Serpent Ashes +7
Man-Serpent Ashes +8
Man-Serpent Ashes +9
Man-Serpents Shield
Manor Towershield
Mantis Blade
Map: Ainsel River
Map: Altus Plateau
Map: Caelid
Map: Consecrated Snowfield
Map: Deeproot Depths
Map: Dragonbarrow
Map: Lake of Rot
Map: Leyndell, Royal Capital
Map: Limgrave, East
Map: Limgrave, West
Map: Liurnia, East
Map: Liurnia, North
Map: Liurnia, West
Map: Mohgwyn Palace
Map: Mountaintops of the Giants, East
Map: Mountaintops of the Giants, West
Map: Mt. Gelmir
Map: Siofra River
Map: Weeping Peninsula
Marais Executioners Sword
Marais Mask
Marais Robe
Margits Shackle
Marikas Hammer
Marikas Scarseal
Marikas Soreseal
Marionette Soldier Armor
Marionette Soldier Ashes
Marionette Soldier Ashes +1
Marionette Soldier Ashes +10
Marionette Soldier Ashes +2
Marionette Soldier Ashes +3
Marionette Soldier Ashes +4
Marionette Soldier Ashes +5
Marionette Soldier Ashes +6
Marionette Soldier Ashes +7
Marionette Soldier Ashes +8
Marionette Soldier Ashes +9
Marionette Soldier Birdhelm
Marionette Soldier Helm
Marred Leather Shield
Marred Wooden Shield
Mask of Confidence
Mausoleum Gauntlets
Mausoleum Greaves
Mausoleum Knight Armor
Mausoleum Knight Armor (Altered)
Mausoleum Knight Gauntlets
Mausoleum Knight Greaves
Mausoleum Soldier Ashes
Mausoleum Soldier Ashes +1
Mausoleum Soldier Ashes +10
Mausoleum Soldier Ashes +2
Mausoleum Soldier Ashes +3
Mausoleum Soldier Ashes +4
Mausoleum Soldier Ashes +5
Mausoleum Soldier Ashes +6
Mausoleum Soldier Ashes +7
Mausoleum Soldier Ashes +8
Mausoleum Soldier Ashes +9
Mausoleum Surcoat
Meat Peddlers Bell Bearing
Medicine Peddlers Bell Bearing
Meeting Place Map
Melted Mushroom
Memory Stone
Memory of Grace
Mending Rune of Perfect Order
Mending Rune of the Death-Prince
Mending Rune of the Fell Curse
Meteor Bolt
Meteoric Ore Blade
Meteorite
Meteorite Staff
Meteorite of Astel
Millicents Boots
Millicents Gloves
Millicents Prosthesis
Millicents Robe
Millicents Tunic
Mimic Tear Ashes
Mimic Tear Ashes +1
Mimic Tear Ashes +10
Mimic Tear Ashes +2
Mimic Tear Ashes +3
Mimic Tear Ashes +4
Mimic Tear Ashes +5
Mimic Tear Ashes +6
Mimic Tear Ashes +7
Mimic Tear Ashes +8
Mimic Tear Ashes +9
Mimics Veil
Miniature Ranni
Miquellan Knights Sword
Miquellas Lily
Miquellas Needle
Mirage Riddle
Miranda Powder
Miranda Sprout Ashes
Miranda Sprout Ashes +1
Miranda Sprout Ashes +10
Miranda Sprout Ashes +2
Miranda Sprout Ashes +3
Miranda Sprout Ashes +4
Miranda Sprout Ashes +5
Miranda Sprout Ashes +6
Miranda Sprout Ashes +7
Miranda Sprout Ashes +8
Miranda Sprout Ashes +9
Mirandas Prayer
Miriels Bell Bearing
Misbegotten Shortbow
Missionarys Cookbook (3)
Missionarys Cookbook :[1]
Missionarys Cookbook :[2]
Missionarys Cookbook :[3]
Missionarys Cookbook :[4]
Missionarys Cookbook :[5]
Missionarys Cookbook :[6]
Missionarys Cookbook :[7]
Miséricorde
Mohgs Great Rune
Mohgs Shackle
Monks Flameblade
Monks Flamemace
Moon of Nokstella
Moonveil
Morgotts Cursed Sword
Morgotts Great Rune
Morning Star
Mottled Necklace
Mottled Necklace +1
Mushroom
Mushroom Arms
Mushroom Body
Mushroom Crown
Mushroom Head
Mushroom Legs
My Lord
My Thanks
Nagakiba
Nascent Butterfly
Navy Hood
Nepheli Loux Puppet
Nepheli Loux Puppet +1
Nepheli Loux Puppet +10
Nepheli Loux Puppet +2
Nepheli Loux Puppet +3
Nepheli Loux Puppet +4
Nepheli Loux Puppet +5
Nepheli Loux Puppet +6
Nepheli Loux Puppet +7
Nepheli Loux Puppet +8
Nepheli Loux Puppet +9
Neutralizing Boluses
Night Comet
Night Maiden Armor
Night Maiden Twin Crown
Night Maidens Mist
Night Shard
Nightmaiden & Swordstress Puppets
Nightmaiden & Swordstress Puppets +1
Nightmaiden & Swordstress Puppets +10
Nightmaiden & Swordstress Puppets +2
Nightmaiden & Swordstress Puppets +3
Nightmaiden & Swordstress Puppets +4
Nightmaiden & Swordstress Puppets +5
Nightmaiden & Swordstress Puppets +6
Nightmaiden & Swordstress Puppets +7
Nightmaiden & Swordstress Puppets +8
Nightmaiden & Swordstress Puppets +9
Nightrider Flail
Nightrider Glaive
Nights Cavalry Armor
Nights Cavalry Armor (Altered)
Nights Cavalry Gauntlets
Nights Cavalry Greaves
Nights Cavalry Helm
Nights Cavalry Helm (Altered)
Noble Presence
Noble Sorcerer Ashes
Noble Sorcerer Ashes +1
Noble Sorcerer Ashes +10
Noble Sorcerer Ashes +2
Noble Sorcerer Ashes +3
Noble Sorcerer Ashes +4
Noble Sorcerer Ashes +5
Noble Sorcerer Ashes +6
Noble Sorcerer Ashes +7
Noble Sorcerer Ashes +8
Noble Sorcerer Ashes +9
Nobles Estoc
Nobles Gloves
Nobles Slender Sword
Nobles Traveling Garb
Nobles Trousers
Nod In Thought
Nomad Ashes
Nomad Ashes +1
Nomad Ashes +10
Nomad Ashes +2
Nomad Ashes +3
Nomad Ashes +4
Nomad Ashes +5
Nomad Ashes +6
Nomad Ashes +7
Nomad Ashes +8
Nomad Ashes +9
Nomadic Merchants Bell Bearing :[10]
Nomadic Merchants Bell Bearing :[11]
Nomadic Merchants Bell Bearing :[1]
Nomadic Merchants Bell Bearing :[2]
Nomadic Merchants Bell Bearing :[3]
Nomadic Merchants Bell Bearing :[4]
Nomadic Merchants Bell Bearing :[5]
Nomadic Merchants Bell Bearing :[6]
Nomadic Merchants Bell Bearing :[7]
Nomadic Merchants Bell Bearing :[8]
Nomadic Merchants Bell Bearing :[9]
Nomadic Merchants Chapeau
Nomadic Merchants Finery
Nomadic Merchants Finery (Altered)
Nomadic Merchants Trousers
Nomadic Warriors Cookbook :[10]
Nomadic Warriors Cookbook :[11]
Nomadic Warriors Cookbook :[12]
Nomadic Warriors Cookbook :[13]
Nomadic Warriors Cookbook :[14]
Nomadic Warriors Cookbook :[15]
Nomadic Warriors Cookbook :[16]
Nomadic Warriors Cookbook :[17]
Nomadic Warriors Cookbook :[18]
Nomadic Warriors Cookbook :[19]
Nomadic Warriors Cookbook :[1]
Nomadic Warriors Cookbook :[20]
Nomadic Warriors Cookbook :[21]
Nomadic Warriors Cookbook :[22]
Nomadic Warriors Cookbook :[23]
Nomadic Warriors Cookbook :[24]
Nomadic Warriors Cookbook :[2]
Nomadic Warriors Cookbook :[3]
Nomadic Warriors Cookbook :[4]
Nomadic Warriors Cookbook :[5]
Nomadic Warriors Cookbook :[6]
Nomadic Warriors Cookbook :[7]
Nomadic Warriors Cookbook :[8]
Nomadic Warriors Cookbook :[9]
Note: Demi-human Mobs
Note: Flame Chariots
Note: Flask of Wondrous Physick
Note: Frenzied Flame Village
Note: Gateway
Note: Gravitys Advantage
Note: Great Coffins
Note: Hidden Cave
Note: Imp Shades
Note: Land Squirts
Note: Miquellas Needle
Note: Revenants
Note: Stonedigger Trolls
Note: The Lord of Frenzied Flame
Note: Unseen Assassins
Note: Walking Mausoleum
Note: Waypoint Ruins
Nox Flowing Hammer
Nox Flowing Sword
Nox Mirrorhelm
Nox Monk Armor
Nox Monk Armor (Altered)
Nox Monk Bracelets
Nox Monk Greaves
Nox Monk Hood
Nox Monk Hood (Altered)
Nox Swordstress Armor
Nox Swordstress Armor (Altered)
Nox Swordstress Crown
Nox Swordstress Crown (Altered)
Numens Rune
O, Flame!
Octopus Head
Officials Attire
Oil Pot
Okina Mask
Old Aristocrat Cowl
Old Aristocrat Gown
Old Aristocrat Shoes
Old Fang
Old Lords Talisman
Old Sorcerers Legwraps
Olivinus Glintstone Crown
Omen Armor
Omen Bairn
Omen Cleaver
Omen Gauntlets
Omen Greaves
Omen Helm
Omenkiller Boots
Omenkiller Long Gloves
Omenkiller Robe
Omenkiller Rollo
Omenkiller Rollo +1
Omenkiller Rollo +10
Omenkiller Rollo +2
Omenkiller Rollo +3
Omenkiller Rollo +4
Omenkiller Rollo +5
Omenkiller Rollo +6
Omenkiller Rollo +7
Omenkiller Rollo +8
Omenkiller Rollo +9
Omensmirk Mask
One-Eyed Shield
Onyx Lords Greatsword
Opaline Bubbletear
Opaline Hardtear
Oracle Bubbles
Oracle Envoy Ashes
Oracle Envoy Ashes +1
Oracle Envoy Ashes +10
Oracle Envoy Ashes +2
Oracle Envoy Ashes +3
Oracle Envoy Ashes +4
Oracle Envoy Ashes +5
Oracle Envoy Ashes +6
Oracle Envoy Ashes +7
Oracle Envoy Ashes +8
Oracle Envoy Ashes +9
Order Healing
Orders Blade
Ordoviss Greatsword
Ornamental Straight Sword
Outer Order
Page Ashes
Page Ashes +1
Page Ashes +10
Page Ashes +2
Page Ashes +3
Page Ashes +4
Page Ashes +5
Page Ashes +6
Page Ashes +7
Page Ashes +8
Page Ashes +9
Page Garb
Page Garb (Altered)
Page Hood
Page Trousers
Parrying Dagger
Partisan
Patches Bell Bearing
Patches Crouch
Pearldrake Talisman
Pearldrake Talisman +1
Pearldrake Talisman +2
Perfume Bottle
Perfumer Gloves
Perfumer Hood
Perfumer Robe
Perfumer Robe (Altered)
Perfumer Sarong
Perfumer Tricia
Perfumer Tricia +1
Perfumer Tricia +10
Perfumer Tricia +2
Perfumer Tricia +3
Perfumer Tricia +4
Perfumer Tricia +5
Perfumer Tricia +6
Perfumer Tricia +7
Perfumer Tricia +8
Perfumer Tricia +9
Perfumers Bolt
Perfumers Cookbook (1)
Perfumers Cookbook (13)
Perfumers Cookbook (2)
Perfumers Cookbook :[1]
Perfumers Cookbook :[2]
Perfumers Cookbook :[3]
Perfumers Cookbook :[4]
Perfumers Shield
Perfumers Talisman
Perfumers Traveling Garb
Perfumers Traveling Garb (Altered)
Pest Threads
Pests Glaive
Phantom Bloody Finger
Phantom Great Rune
Phantom Recusant Finger
Pickaxe
Pickled Turtle Neck
Pidias Bell Bearing
Pike
Pillory Shield
Placidusaxs Ruin
Point Downwards
Point Forwards
Point Upwards
Poison Armament
Poison Grease
Poison Mist
Poison Pot
Poison Spraymist
Poisonbloom
Poisonbone Arrow
Poisonbone Arrow (Fletched)
Poisonbone Bolt
Poisonbone Dart
Poisoned Stone
Poisoned Stone Clump
Polite Bow
Prattling Pate Apologies
Prattling Pate Hello
Prattling Pate Lets get to it
Prattling Pate My beloved
Prattling Pate Please help
Prattling Pate Thank you
Prattling Pate Wonderful
Prattling Pate Youre beautiful
Prayer
Preceptors Big Hat
Preceptors Gloves
Preceptors Long Gown
Preceptors Long Gown (Altered)
Preceptors Trousers
Prelates Inferno Crozier
Preserving Boluses
Primal Glintstone Blade
Prince of Deaths Cyst
Prince of Deaths Pustule
Prince of Deaths Staff
Prisoner Clothing
Prisoner Iron Mask
Prisoner Trousers
Prophecy Painting
Prophet Blindfold
Prophet Robe
Prophet Robe (Altered)
Prophet Trousers
Prosthesis-Wearer Heirloom
Protection of the Erdtree
Pulley Bow
Pulley Crossbow
Pumpkin Helm
Pureblood Knights Medal
Purifying Crystal Tear
Putrid Corpse Ashes
Putrid Corpse Ashes +1
Putrid Corpse Ashes +10
Putrid Corpse Ashes +2
Putrid Corpse Ashes +3
Putrid Corpse Ashes +4
Putrid Corpse Ashes +5
Putrid Corpse Ashes +6
Putrid Corpse Ashes +7
Putrid Corpse Ashes +8
Putrid Corpse Ashes +9
Queens Bracelets
Queens Crescent Crown
Queens Leggings
Queens Robe
Radagon Icon
Radagons Rings of Light
Radagons Scarseal
Radagons Soreseal
Radahn Soldier Ashes
Radahn Soldier Ashes +1
Radahn Soldier Ashes +10
Radahn Soldier Ashes +2
Radahn Soldier Ashes +3
Radahn Soldier Ashes +4
Radahn Soldier Ashes +5
Radahn Soldier Ashes +6
Radahn Soldier Ashes +7
Radahn Soldier Ashes +8
Radahn Soldier Ashes +9
Radahn Soldier Gauntlets
Radahn Soldier Greaves
Radahn Soldier Helm
Radahns Gauntlets
Radahns Great Rune
Radahns Greaves
Radahns Lion Armor
Radahns Lion Armor (Altered)
Radahns Redmane Helm
Radahns Spear
Radiant Baldachins Blessing
Radiant Gold Mask
Ragged Armor
Ragged Armor (Altered)
Ragged Gloves
Ragged Hat
Ragged Hat (Altered)
Ragged Loincloth
Raging Wolf Armor
Raging Wolf Armor (Altered)
Raging Wolf Gauntlets
Raging Wolf Greaves
Raging Wolf Helm
Rainbow Stone
Rainbow Stone Arrow
Rainbow Stone Arrow (Fletched)
Rallying Cry
Rancor Pot
Rancorcall
Rannis Dark Moon
Rapier
Raptor Talons
Raptors Black Feathers
Rapture
Raw Meat Dumpling
Raya Lucaria Soldier Ashes
Raya Lucaria Soldier Ashes +1
Raya Lucaria Soldier Ashes +10
Raya Lucaria Soldier Ashes +2
Raya Lucaria Soldier Ashes +3
Raya Lucaria Soldier Ashes +4
Raya Lucaria Soldier Ashes +5
Raya Lucaria Soldier Ashes +6
Raya Lucaria Soldier Ashes +7
Raya Lucaria Soldier Ashes +8
Raya Lucaria Soldier Ashes +9
Raya Lucarian Gauntlets
Raya Lucarian Greaves
Raya Lucarian Helm
Raya Lucarian Robe
Recusant Finger
Red Branch Shortbow
Red Crest Heater Shield
Red Letter
Red Thorn Roundshield
Red-Feathered Branchsword
Red-Hot Whetblade
Redmane Fire Pot
Redmane Greatshield
Redmane Knight Armor
Redmane Knight Armor (Altered)
Redmane Knight Gauntlets
Redmane Knight Greaves
Redmane Knight Helm
Redmane Knight Ogha
Redmane Knight Ogha +1
Redmane Knight Ogha +10
Redmane Knight Ogha +2
Redmane Knight Ogha +3
Redmane Knight Ogha +4
Redmane Knight Ogha +5
Redmane Knight Ogha +6
Redmane Knight Ogha +7
Redmane Knight Ogha +8
Redmane Knight Ogha +9
Redmane Painting
Redmane Surcoat
Reduvia
Regal Omen Bairn
Regalia of Eochaid
Rejection
Rejuvenating Boluses
Remembrance of Hoarah Loux
Remembrance of the Black Blade
Remembrance of the Blasphemous
Remembrance of the Blood Lord
Remembrance of the Dragonlord
Remembrance of the Fire Giant
Remembrance of the Full Moon Queen
Remembrance of the Grafted
Remembrance of the Lichdragon
Remembrance of the Naturalborn
Remembrance of the Omen King
Remembrance of the Regal Ancestor
Remembrance of the Rot Goddess
Remembrance of the Starscourge
Rennalas Full Moon
Rest
Resurrection Painting
Reverential Bow
Rickety Shield
Rift Shield
Rimed Crystal Bud
Rimed Rowa
Ringed Finger
Ripple Blade
Ripple Crescent Halberd
Ritual Pot
Ritual Shield Talisman
Ritual Sword Talisman
Rivers of Blood
Riveted Wooden Shield
Roar Medallion
Rock Blaster
Rock Sling
Rogiers Bell Bearing
Rogiers Letter
Rogiers Rapier
Roiling Magma
Rold Medallion
Ronins Armor
Ronins Armor (Altered)
Ronins Gauntlets
Ronins Greaves
Root Resin
Roped Fetid Pot
Roped Fire Pot
Roped Fly Pot
Roped Freezing Pot
Roped Holy Water Pot
Roped Lightning Pot
Roped Magic Pot
Roped Oil Pot
Roped Poison Pot
Roped Volcano Pot
Rosus Axe
Rot Grease
Rot Pot
Rotbone Arrow
Rotbone Arrow (Fletched)
Rotbone Bolt
Rotten Battle Hammer
Rotten Breath
Rotten Crystal Spear
Rotten Crystal Staff
Rotten Crystal Sword
Rotten Duelist Greaves
Rotten Duelist Helm
Rotten Gravekeeper Cloak
Rotten Gravekeeper Cloak (Altered)
Rotten Greataxe
Rotten Staff
Rotten Stray Ashes
Rotten Stray Ashes +1
Rotten Stray Ashes +10
Rotten Stray Ashes +2
Rotten Stray Ashes +3
Rotten Stray Ashes +4
Rotten Stray Ashes +5
Rotten Stray Ashes +6
Rotten Stray Ashes +7
Rotten Stray Ashes +8
Rotten Stray Ashes +9
Rotten Winged Sword Insignia
Round Shield
Rowa Fruit
Rowa Raisin
Royal Greatsword
Royal House Scroll
Royal Knight Armor
Royal Knight Armor (Altered)
Royal Knight Gauntlets
Royal Knight Greaves
Royal Knight Helm
Royal Remains Armor
Royal Remains Gauntlets
Royal Remains Greaves
Royal Remains Helm
Ruin Fragment
Ruins Greatsword
Rulers Mask
Rulers Robe
Rune Arc
Ruptured Crystal Tear
Rusted Anchor
Rusty Key
Ryas Necklace
Rykards Great Rune
Rykards Rancor
Sacramental Bud
Sacred Crown Helm
Sacred Order Pot
Sacred Scorpion Charm
Sacred Tear
Sacrificial Axe
Sacrificial Twig
Sage Hood
Sage Robe
Sage Trousers
Sanctified Whetblade
Sanctuary Stone
Sanguine Noble Hood
Sanguine Noble Robe
Sanguine Noble Waistcloth
Scale Armor
Scaled Armor
Scaled Armor (Altered)
Scaled Gauntlets
Scaled Greaves
Scaled Helm
Scarlet Aeonia
Scarlet Tabard
Scavengers Curved Sword
Scepter of the All-Knowing
Scholars Armament
Scholars Shield
Scimitar
Scorpion Kite Shield
Scorpions Stinger
Scouring Black Flame
Scriptstone
Scripture Wooden Shield
Scythe
Seedbed Curse
Sellens Bell Bearing
Sellens Primal Glintstone
Sellian Sealbreaker
Sellias Secret
Seluviss Bell Bearing
Seluviss Introduction
Seluviss Potion
Sentrys Torch
Serpent Arrow
Serpent Bow
Serpent-Gods Curved Sword
Serpent-Hunter
Serpentbone Blade
Serpents Amnion
Sewer-Gaol Key
Sewing Needle
Shabriri Grape
Shabriris Woe
Shadow Bait
Shaman Furs
Shaman Leggings
Shamshir
Shard Spiral
Shard of Alexander
Shatter Earth
Shattering Crystal
Shattershard Arrow
Shattershard Arrow (Fletched)
Shield Grease
Shield of the Guilty
Shining Horned Headband
Short Spear
Short Sword
Shortbow
Shotel
Silurias Tree
Silver Firefly
Silver Mirrorshield
Silver Scarab
Silver Tear Husk
Silver Tear Mask
Silver-Pickled Fowl Foot
Sitting Sideways
Skeletal Bandit Ashes
Skeletal Bandit Ashes +1
Skeletal Bandit Ashes +10
Skeletal Bandit Ashes +2
Skeletal Bandit Ashes +3
Skeletal Bandit Ashes +4
Skeletal Bandit Ashes +5
Skeletal Bandit Ashes +6
Skeletal Bandit Ashes +7
Skeletal Bandit Ashes +8
Skeletal Bandit Ashes +9
Skeletal Mask
Skeletal Militiaman Ashes
Skeletal Militiaman Ashes +1
Skeletal Militiaman Ashes +10
Skeletal Militiaman Ashes +2
Skeletal Militiaman Ashes +3
Skeletal Militiaman Ashes +4
Skeletal Militiaman Ashes +5
Skeletal Militiaman Ashes +6
Skeletal Militiaman Ashes +7
Skeletal Militiaman Ashes +8
Skeletal Militiaman Ashes +9
Sleep Pot
Sleepbone Arrow
Sleepbone Arrow (Fletched)
Sleepbone Bolt
Sliver of Meat
Slumbering Egg
Small Golden Effigy
Small Red Effigy
Smarags Glintstone Breath
Smithing Stone :[1]
Smithing Stone :[2]
Smithing Stone :[3]
Smithing Stone :[4]
Smithing Stone :[5]
Smithing Stone :[6]
Smithing Stone :[7]
Smithing Stone :[8]
Smithing-Stone Miners Bell Bearing :[1]
Smithing-Stone Miners Bell Bearing :[2]
Smithing-Stone Miners Bell Bearing :[3]
Smithing-Stone Miners Bell Bearing :[4]
Smoldering Butterfly
Smoldering Shield
Snow Witch Hat
Snow Witch Robe
Snow Witch Robe (Altered)
Snow Witch Skirt
Soap
Soft Cotton
Soldiers Crossbow
Soldjars of Fortune Ashes
Soldjars of Fortune Ashes +1
Soldjars of Fortune Ashes +10
Soldjars of Fortune Ashes +2
Soldjars of Fortune Ashes +3
Soldjars of Fortune Ashes +4
Soldjars of Fortune Ashes +5
Soldjars of Fortune Ashes +6
Soldjars of Fortune Ashes +7
Soldjars of Fortune Ashes +8
Soldjars of Fortune Ashes +9
Somber Ancient Dragon Smithing Stone
Somber Smithing Stone :[1]
Somber Smithing Stone :[2]
Somber Smithing Stone :[3]
Somber Smithing Stone :[4]
Somber Smithing Stone :[5]
Somber Smithing Stone :[6]
Somber Smithing Stone :[7]
Somber Smithing Stone :[8]
Somber Smithing Stone :[9]
Somberstone Miners Bell Bearing :[1]
Somberstone Miners Bell Bearing :[2]
Somberstone Miners Bell Bearing :[3]
Somberstone Miners Bell Bearing :[4]
Somberstone Miners Bell Bearing :[5]
Soporific Grease
Sorcerer Leggings
Sorcerer Manchettes
Sorcerer Painting
Spark Aromatic
Spear
Spear Talisman
Speckled Hardtear
Spectral Steed Whistle
Spellblades Gloves
Spellblades Pointed Hat
Spellblades Traveling Attire
Spellblades Traveling Attire (Altered)
Spellblades Trousers
Spelldrake Talisman
Spelldrake Talisman +1
Spelldrake Talisman +2
Spellproof Dried Liver
Spiked Caestus
Spiked Club
Spiked Cracked Tear
Spiked Palisade Shield
Spiked Spear
Spiralhorn Shield
Spirit Calling Bell
Spirit Jellyfish Ashes
Spirit Jellyfish Ashes +1
Spirit Jellyfish Ashes +10
Spirit Jellyfish Ashes +2
Spirit Jellyfish Ashes +3
Spirit Jellyfish Ashes +4
Spirit Jellyfish Ashes +5
Spirit Jellyfish Ashes +6
Spirit Jellyfish Ashes +7
Spirit Jellyfish Ashes +8
Spirit Jellyfish Ashes +9
Spiritflame Arrow
Spread Out
St. Trinas Arrow
St. Trinas Torch
Staff of Loss
Staff of the Avatar
Staff of the Guilty
Stalwart Horn Charm
Stalwart Horn Charm +1
Stanching Boluses
Star Fist
Star Shower
Stargazer Heirloom
Starlight
Starlight Shards
Stars of Ruin
Starscourge Greatsword
Starscourge Heirloom
Steel-Wire Torch
Stimulating Boluses
Stone Club
Stone of Gurranq
Stonebarb Cracked Tear
Stonesword Key
Stormhawk Axe
Stormhawk Deenh
Stormhawk Deenh +1
Stormhawk Deenh +10
Stormhawk Deenh +2
Stormhawk Deenh +3
Stormhawk Deenh +4
Stormhawk Deenh +5
Stormhawk Deenh +6
Stormhawk Deenh +7
Stormhawk Deenh +8
Stormhawk Deenh +9
Stormhawk Feather
Stormwing Bone Arrow
Strength!
Strength-knot Crystal Tear
String
Strip of White Flesh
Sun Realm Shield
Surge, O Flame!
Swarm Pot
Swarm of Flies
Sweet Raisin
Swift Glintstone Shard
Sword of Milos
Sword of Night and Flame
Sword of St. Trina
Tailoring Tools
Takers Cameo
Talisman Pouch
Tarnished Golden Sunflower
Tarnished Wizened Finger
Tarnisheds Furled Finger
Taunters Tongue
Telescope
Terra Magicus
Thawfrost Boluses
The Flame of Frenzy
The Ring
The Stormhawk King
Theodorixs Magma
Thin Beast Bones
Thopss Barrier
Thopss Bell Bearing
Thorned Whip
Thorny Cracked Tear
Throwing Dagger
Tibias Summons
Tonic of Forgetfulness
Torch
Torchpole
Toxic Mushroom
Travelers Boots
Travelers Clothes
Travelers Gloves
Travelers Hat
Travelers Manchettes
Travelers Slops
Traveling Maiden Boots
Traveling Maiden Gloves
Traveling Maiden Hood
Traveling Maiden Robe
Traveling Maiden Robe (Altered)
Tree Sentinel Armor
Tree Sentinel Armor (Altered)
Tree Sentinel Gauntlets
Tree Sentinel Greaves
Tree Sentinel Helm
Tree Surcoat
Tree-and-Beast Surcoat
Treespear
Trinas Lily
Triple Rings of Light
Triumphant Delight
Troll Knights Sword
Trolls Golden Sword
Trolls Hammer
Turtle Neck Meat
Twiggy Cracked Tear
Twinbird Kite Shield
Twinblade
Twinblade Talisman
Twinned Armor
Twinned Armor (Altered)
Twinned Gauntlets
Twinned Greaves
Twinned Helm
Twinned Knight Swords
Twinsage Glintstone Crown
Twinsage Sorcerer Ashes
Twinsage Sorcerer Ashes +1
Twinsage Sorcerer Ashes +10
Twinsage Sorcerer Ashes +2
Twinsage Sorcerer Ashes +3
Twinsage Sorcerer Ashes +4
Twinsage Sorcerer Ashes +5
Twinsage Sorcerer Ashes +6
Twinsage Sorcerer Ashes +7
Twinsage Sorcerer Ashes +8
Twinsage Sorcerer Ashes +9
Two Fingers Heirloom
Two Fingers Prayerbook
Uchigatana
Unalloyed Gold Needle
Unarmed
Unendurable Frenzy
Unseen Blade
Unseen Form
Uplifting Aromatic
Upper-Class Robe
Urgent Heal
Urumi
Vagabond Knight Armor
Vagabond Knight Armor (Altered)
Vagabond Knight Gauntlets
Vagabond Knight Greaves
Vagabond Knight Helm
Valkyries Prosthesis
Varrés Bouquet
Venomous Fang
Veterans Armor
Veterans Armor (Altered)
Veterans Gauntlets
Veterans Greaves
Veterans Helm
Veterans Prosthesis
Viridian Amber Medallion
Viridian Amber Medallion +1
Viridian Amber Medallion +2
Visage Shield
Volcanic Stone
Volcano Manor Invitation
Volcano Pot
Vulgar Militia Armor
Vulgar Militia Ashes
Vulgar Militia Ashes +1
Vulgar Militia Ashes +10
Vulgar Militia Ashes +2
Vulgar Militia Ashes +3
Vulgar Militia Ashes +4
Vulgar Militia Ashes +5
Vulgar Militia Ashes +6
Vulgar Militia Ashes +7
Vulgar Militia Ashes +8
Vulgar Militia Ashes +9
Vulgar Militia Gauntlets
Vulgar Militia Greaves
Vulgar Militia Helm
Vulgar Militia Saw
Vulgar Militia Shotel
Vykes Dragonbolt
Vykes War Spear
Wait!
Wakizashi
Wandering Noble Ashes
Wandering Noble Ashes +1
Wandering Noble Ashes +10
Wandering Noble Ashes +2
Wandering Noble Ashes +3
Wandering Noble Ashes +4
Wandering Noble Ashes +5
Wandering Noble Ashes +6
Wandering Noble Ashes +7
Wandering Noble Ashes +8
Wandering Noble Ashes +9
War Surgeon Gloves
War Surgeon Gown
War Surgeon Gown (Altered)
War Surgeon Trousers
Warhawk Ashes
Warhawk Ashes +1
Warhawk Ashes +10
Warhawk Ashes +2
Warhawk Ashes +3
Warhawk Ashes +4
Warhawk Ashes +5
Warhawk Ashes +6
Warhawk Ashes +7
Warhawk Ashes +8
Warhawk Ashes +9
Warhawks Talon
Warm Welcome
Warming Stone
Warped Axe
Warpick
Warrior Gauntlets
Warrior Greaves
Warrior Jar Shard
Watchdogs Greatsword
Watchdogs Staff
Wave
Weathered Dagger
Weathered Straight Sword
What Do You Want?
Whetstone Knife
Whip
Whirl, O Flame!
White Cipher Ring
White Mask
White Reed Armor
White Reed Gauntlets
White Reed Greaves
Windy Crystal Tear
Wing of Astel
Winged Crystal Tear
Winged Greathorn
Winged Misbegotten Ashes
Winged Misbegotten Ashes + 1
Winged Misbegotten Ashes + 10
Winged Misbegotten Ashes + 2
Winged Misbegotten Ashes + 3
Winged Misbegotten Ashes + 4
Winged Misbegotten Ashes + 5
Winged Misbegotten Ashes + 6
Winged Misbegotten Ashes + 7
Winged Misbegotten Ashes + 8
Winged Misbegotten Ashes + 9
Winged Scythe
Winged Sword Insignia
Witchs Glintstone Crown
Wooden Greatshield
Wraith Calling Bell
Wrath of Gold
Yellow Ember
Zamor Armor
Zamor Bracelets
Zamor Curved Sword
Zamor Ice Storm
Zamor Legwraps
Zamor Mask
Zorayass Letter
Zweihander
