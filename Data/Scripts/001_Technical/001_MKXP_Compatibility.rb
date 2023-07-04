# Using mkxp-z v2.2.0 - https://gitlab.com/mkxp-z/mkxp-z/-/releases/v2.2.0
$VERBOSE = nil
$POTENTIALSPRITES = {}
$DEFAULTSPRITES = {}

$KURAY_BLACKLIST = [
  "130a","150a","150b","150d","150g","150i","150l","150o","15b","17d","1a","212b","212d","215g","284d",
  "284f","287g","287p","300c","310c","310d","336c","354g","357c","415z","94j","94l","92a","93c","94d","133g","138b","368j","370a",
  "411a","408b","402a","402b","140d","220a","146d","171c","172c","218a","227e","288f","324b","331b","350b","354j","360b","360c","360d","384c","392k","413a",
  "417c","417d","418b","194b"
]
$KURAY_COMMONLIST = [
  "390c","132e"
] # 30%
$KURAY_RARELIST = [
  "390b","68c","115d","132c","201_kuc","201_kub"
] # 6%
$KURAY_VERYRARELIST = [
  "390a","50a","52i","94g","100a","100c","101b","102a","102d","104c","102a","132a","133d","135b","143e","155b","155f","157g","158a","165b","175d","202a","265e","287d","294b",
  "296d","296f","301c","307a","314h","319d","321c","321d","338i","339g","339f","339b","352b","352m","358a","361a","369c","414c","415b","201a","201b","201c"
] # 2% ~Jokes and Alt
$KURAY_LEGENDLIST = [
  "37a","38l","51a","52j","53g","53h","59b","72a","73a","76a","77a","77c","78a","78g","79f","80c","100d","100f","101d","103a","144b","145a","145b","146b","146g","155e","157a",
  "157c","195a","217a","245a","315f","336a","336h","338f","348a","399b","399c","411c",
  "201_shinya","201_shinyaa","201_shinyab","201_shinyac","201_shinyad","201_shinyae","201_shinyaf","201_shinyag","201_shinyah","201_shinyai","201_shinyaj","201_shinyb","201_shinyba",
  "201_shinybb","201_shinybc","201_shinybd","201_shinybe","201_shinybf","201_shinybg","201_shinybh","201_shinybj","201_shinyc","201_shinyd","201_shinye","201_shinyf","201_shinyi"
] # 0.5% ~Regional
$KURAY_MYTHICLIST = [
  "249c","249k","249l","290b","315e","381e",
  "201_shinyg","201_shinyh"
] # 0.1% ~Shadow Lugia etc

#Potential fusions mistakes:
# 202a
# 287d 321c 321d
#~ end of PFM

#Missnamed
# 288f Steelix but on Gallame
#~ end of MN

Font.default_shadow = false if Font.respond_to?(:default_shadow)
Graphics.frame_rate = 40

def pbSetWindowText(string)
  System.set_window_title(string || System.game_title)
  # System.set_window_title(System.game_title + " | Kuray's Shiny Revamp | Speed: x1")
end

##### Kuray's Global Functions #####

def kurayRNGforChannels
  kurayRNG = rand(0..10000)
  if kurayRNG < 5
    return rand(0..11)
  elsif kurayRNG < 41
    return rand(0..8)
  elsif kurayRNG < 2041
    return rand(0..5)
  else
    return rand(0..2)
  end
  # 0.04% chance to have an inverse magenta/yellow/cyan
  # 0.4% chance to have an inverse (4/1000*100)
  # 4% chance to have Cyan/Magenta/Yellow (40/1000*100)
  # change Cyan/Magenta/Yellow to 20%
end

def kurayPlayerBlackList(dex_number, filename)
  if dex_number <= Settings::NB_POKEMON
    #Check for non fusions
    usinglocation = "Graphics/KuraySprites/"
    filefile = File.basename(filename)
    Dir.mkdir(usinglocation + "Disabled") unless File.exists?(usinglocation + "Disabled")
    File.delete(usinglocation + "Disabled/" + filefile) if File.exists?(usinglocation + "Disabled/" + filefile)
    File.rename(filename, usinglocation + "Disabled/" + filefile) if File.exists?(filename)
    kuraychose = kurayGetCustomNonFusion(dex_number)
    return nil if kuraychose == nil
    return kuraychose
  else
    if dex_number >= Settings::ZAPMOLCUNO_NB
      # kuraychose = kurayGetCustomTripleFusion(dex_number)
      return nil
      # Check for triple fusions
      # specialPath = getSpecialSpriteName(dex_number)
      # return pbResolveBitmap(specialPath)
      # head_id=nil
    else
      # Check for double fusion
      body_id = getBodyID(dex_number)
      head_id = getHeadID(dex_number, body_id)
      usinglocation = Settings::CUSTOM_BATTLERS_FOLDER_INDEXED + head_id.to_s + "/"
      filefile = File.basename(filename)
      Dir.mkdir(usinglocation + "Disabled") unless File.exists?(usinglocation + "Disabled")
      File.delete(usinglocation + "Disabled/" + filefile) if File.exists?(usinglocation + "Disabled/" + filefile)
      File.rename(filename, usinglocation + "Disabled/" + filefile) if File.exists?(filename)
      kuraychose = kurayGetCustomDoubleFusion(dex_number, head_id, body_id)
      return nil if kuraychose == nil
      return kuraychose
    end
  end
end

def isKurayDefaultSprite(dex_number, filename)
  return false if dex_number == nil
  return false if filename == nil
  if dex_number <= Settings::NB_POKEMON
    #Check for non fusions
    filefile = File.basename(filename)
    dexname = filefile.split('.png')[0]
    return true if dexname.to_s == dex_number.to_s
    return false
  else
    if dex_number >= Settings::ZAPMOLCUNO_NB
      return false
    else
      # Check for double fusion
      body_id = getBodyID(dex_number)
      head_id = getHeadID(dex_number, body_id)
      filefile = File.basename(filename)
      dexname = filefile.split('.png')[0]
      return true if dexname.to_s == head_id.to_s + "." + body_id.to_s
      return false
    end
  end
  return nil
end

def kurayRNGSprite(dex_number, usedefault=0)
  $DEFAULTSPRITES = {} if !$DEFAULTSPRITES
  if usedefault != 0 && $DEFAULTSPRITES.has_key?(dex_number.to_s)
    return $DEFAULTSPRITES[dex_number.to_s]
  end
  probs = 0
  probs += 1000 if !$POTENTIALSPRITES[dex_number].empty?
  probs += 300 if !$POTENTIALSPRITES[dex_number.to_s + "_common"].empty?
  probs += 60 if !$POTENTIALSPRITES[dex_number.to_s + "_rare"].empty?
  probs += 20 if !$POTENTIALSPRITES[dex_number.to_s + "_veryrare"].empty?
  probs += 5 if !$POTENTIALSPRITES[dex_number.to_s + "_legend"].empty?
  probs += 1 if !$POTENTIALSPRITES[dex_number.to_s + "_mythic"].empty?
  if probs == 0
    return nil
  end
  if probs == 1
    return $POTENTIALSPRITES[dex_number.to_s + "_mythic"].sample
  end
  rngkuray = rand(1..probs)
  if rngkuray < 1+1 && !$POTENTIALSPRITES[dex_number.to_s + "_mythic"].empty?
    return $POTENTIALSPRITES[dex_number.to_s + "_mythic"].sample
    # got mythic
  end
  rngkuray -= 1 if $POTENTIALSPRITES[dex_number.to_s + "_mythic"].empty?
  if rngkuray < 5+1 && !$POTENTIALSPRITES[dex_number.to_s + "_legend"].empty?
    return $POTENTIALSPRITES[dex_number.to_s + "_legend"].sample
    # got legend
  end
  rngkuray -= 5 if $POTENTIALSPRITES[dex_number.to_s + "_legend"].empty?
  if rngkuray < 20+1 && !$POTENTIALSPRITES[dex_number.to_s + "_veryrare"].empty?
    return $POTENTIALSPRITES[dex_number.to_s + "_veryrare"].sample
    # got veryrare
  end
  rngkuray -= 20 if $POTENTIALSPRITES[dex_number.to_s + "_veryrare"].empty?
  if rngkuray < 60+1 && !$POTENTIALSPRITES[dex_number.to_s + "_rare"].empty?
    return $POTENTIALSPRITES[dex_number.to_s + "_rare"].sample
    # got rare
  end
  rngkuray -= 60 if $POTENTIALSPRITES[dex_number.to_s + "_rare"].empty?
  if rngkuray < 300+1 && !$POTENTIALSPRITES[dex_number.to_s + "_common"].empty?
    return $POTENTIALSPRITES[dex_number.to_s + "_common"].sample
    # got common
  end
  rngkuray -= 300 if $POTENTIALSPRITES[dex_number.to_s + "_common"].empty?
  if rngkuray < 1000+1 && !$POTENTIALSPRITES[dex_number].empty?
    return $POTENTIALSPRITES[dex_number].sample
    # got normal
  end
  if !$POTENTIALSPRITES[dex_number].empty?
    return $POTENTIALSPRITES[dex_number].sample
  else
    return nil
  end
end

def kurayGetCustomNonFusion(dex_number, usedefault=0)
  #Settings::CUSTOM_BASE_SPRITES_FOLDER
  $DEFAULTSPRITES = {} if !$DEFAULTSPRITES
  $POTENTIALSPRITES = {} if !$POTENTIALSPRITES
  $POTENTIALSPRITES[dex_number] = [] if !$POTENTIALSPRITES[dex_number]
  $POTENTIALSPRITES[dex_number.to_s + "_common"] = [] if !$POTENTIALSPRITES[dex_number.to_s + "_common"]
  $POTENTIALSPRITES[dex_number.to_s + "_rare"] = [] if !$POTENTIALSPRITES[dex_number.to_s + "_rare"]
  $POTENTIALSPRITES[dex_number.to_s + "_veryrare"] = [] if !$POTENTIALSPRITES[dex_number.to_s + "_veryrare"]
  $POTENTIALSPRITES[dex_number.to_s + "_legend"] = [] if !$POTENTIALSPRITES[dex_number.to_s + "_legend"]
  $POTENTIALSPRITES[dex_number.to_s + "_mythic"] = [] if !$POTENTIALSPRITES[dex_number.to_s + "_mythic"]
  # usinglocation = "Graphics/Base Sprites/"
  usinglocation = "Graphics/KuraySprites/"
  if $POTENTIALSPRITES[dex_number].empty?
    # Only keep files that correspond to the actual pokemon
    # Dir.foreach(Settings::CUSTOM_BASE_SPRITES_FOLDER + dex_number.to_s + "*") do |filename|
    files = Dir[usinglocation + dex_number.to_s + "*.png"]
    files.each do |filename|
      next if filename == '.' or filename == '..'
      next if !filename.end_with?(".png")
      next if filename.end_with?("_i.png")
      filefile = File.basename(filename)
      dexname = filefile.split('.png')[0]
      if dexname.to_s == dex_number.to_s && !$DEFAULTSPRITES.has_key?(dex_number.to_s)
        $DEFAULTSPRITES[dex_number.to_s] = filefile
      end
      if $KURAY_BLACKLIST.include?(dexname)
        Dir.mkdir(usinglocation + "Disabled") unless File.exists?(usinglocation + "Disabled")
        File.delete(usinglocation + "Disabled/" + filefile) if File.exists?(usinglocation + "Disabled/" + filefile)
        File.rename(filename, usinglocation + "Disabled/" + filefile) if File.exists?(filename)
        next
      end
      checknumber = dexname.gsub(/[^\d]/, '')
      next if checknumber.to_i != dex_number
      if $KURAY_COMMONLIST.include?(dexname)
        $POTENTIALSPRITES[dex_number.to_s + "_common"].append(filefile)
      elsif $KURAY_RARELIST.include?(dexname)
        $POTENTIALSPRITES[dex_number.to_s + "_rare"].append(filefile)
      elsif $KURAY_VERYRARELIST.include?(dexname)
        $POTENTIALSPRITES[dex_number.to_s + "_veryrare"].append(filefile)
      elsif $KURAY_LEGENDLIST.include?(dexname)
        $POTENTIALSPRITES[dex_number.to_s + "_legend"].append(filefile)
      elsif $KURAY_MYTHICLIST.include?(dexname)
        $POTENTIALSPRITES[dex_number.to_s + "_mythic"].append(filefile)
      else
        $POTENTIALSPRITES[dex_number].append(filefile)
      end
    end
    # Choose randomly from the array
    kuraycusfile = kurayRNGSprite(dex_number, usedefault)
    return nil if kuraycusfile == nil
    return usinglocation + kuraycusfile
  else
    # Choose randomly from the array
    kuraycusfile = kurayRNGSprite(dex_number, usedefault)
    return nil if kuraycusfile == nil
    return usinglocation + kuraycusfile
  end
  return nil
end


def kurayGetCustomTripleFusion(dex_number)
  #Unused as of right now
  #getSpecialSpriteName needs to be public
end

def kurayGetCustomDoubleFusion(dex_number, head_id, body_id, usedefault=0)
  #Settings::CUSTOM_BATTLERS_FOLDER_INDEXED
  $DEFAULTSPRITES = {} if !$DEFAULTSPRITES
  $POTENTIALSPRITES = {} if !$POTENTIALSPRITES
  $POTENTIALSPRITES[dex_number] = [] if !$POTENTIALSPRITES[dex_number]
  $POTENTIALSPRITES[dex_number.to_s + "_common"] = [] if !$POTENTIALSPRITES[dex_number.to_s + "_common"]
  $POTENTIALSPRITES[dex_number.to_s + "_rare"] = [] if !$POTENTIALSPRITES[dex_number.to_s + "_rare"]
  $POTENTIALSPRITES[dex_number.to_s + "_veryrare"] = [] if !$POTENTIALSPRITES[dex_number.to_s + "_veryrare"]
  $POTENTIALSPRITES[dex_number.to_s + "_legend"] = [] if !$POTENTIALSPRITES[dex_number.to_s + "_legend"]
  $POTENTIALSPRITES[dex_number.to_s + "_mythic"] = [] if !$POTENTIALSPRITES[dex_number.to_s + "_mythic"]
  usinglocation = Settings::CUSTOM_BATTLERS_FOLDER_INDEXED + head_id.to_s + "/"
  if $POTENTIALSPRITES[dex_number].empty?
    # Only keep files that correspond to the actual pokemon
    files = Dir[usinglocation + head_id.to_s + "." + body_id.to_s + "*.png"]
    files.each do |filename|
      next if filename == '.' or filename == '..'
      next if !filename.end_with?(".png")
      next if filename.end_with?("_i.png")
      filefile = File.basename(filename)
      dexname = filefile.split('.png')[0]
      if dexname.to_s == head_id.to_s + "." + body_id.to_s && !$DEFAULTSPRITES.has_key?(dex_number.to_s)
        $DEFAULTSPRITES[dex_number.to_s] = filefile
      end
      if $KURAY_BLACKLIST.include?(dexname)
        Dir.mkdir(usinglocation + "Disabled") unless File.exists?(usinglocation + "Disabled")
        File.delete(usinglocation + "Disabled/" + filefile) if File.exists?(usinglocation + "Disabled/" + filefile)
        File.rename(filename, usinglocation + "Disabled/" + filefile) if File.exists?(filename)
        next
      end
      checknumber = dexname.gsub(/[^\d.]/, '')
      next if checknumber.to_s != head_id.to_s + "." + body_id.to_s
      if $KURAY_COMMONLIST.include?(dexname)
        $POTENTIALSPRITES[dex_number.to_s + "_common"].append(filefile)
      elsif $KURAY_RARELIST.include?(dexname)
        $POTENTIALSPRITES[dex_number.to_s + "_rare"].append(filefile)
      elsif $KURAY_VERYRARELIST.include?(dexname)
        $POTENTIALSPRITES[dex_number.to_s + "_veryrare"].append(filefile)
      elsif $KURAY_LEGENDLIST.include?(dexname)
        $POTENTIALSPRITES[dex_number.to_s + "_legend"].append(filefile)
      elsif $KURAY_MYTHICLIST.include?(dexname)
        $POTENTIALSPRITES[dex_number.to_s + "_mythic"].append(filefile)
      else
        $POTENTIALSPRITES[dex_number].append(filefile)
      end
    end
    # Choose randomly from the array
    kuraycusfile = kurayRNGSprite(dex_number, usedefault)
    return nil if kuraycusfile == nil
    return usinglocation + kuraycusfile
  else
    # Choose randomly from the array
    kuraycusfile = kurayRNGSprite(dex_number, usedefault)
    return nil if kuraycusfile == nil
    return usinglocation + kuraycusfile
  end
  return nil
end

# KurayX Allow to have multiple pokemons uses different sprites, generate sprite from filename for the Pokemon.
def kurayGetCustomSprite(dex_number, usedefault=0)
  return nil if dex_number == nil
  if dex_number <= Settings::NB_POKEMON
    #Check for non fusions
    kuraychose = kurayGetCustomNonFusion(dex_number, usedefault)
    return nil if kuraychose == nil
    return kuraychose
  else
    if dex_number >= Settings::ZAPMOLCUNO_NB
      # kuraychose = kurayGetCustomTripleFusion(dex_number)
      return nil
      # Check for triple fusions
      # specialPath = getSpecialSpriteName(dex_number)
      # return pbResolveBitmap(specialPath)
      # head_id=nil
    else
      # Check for double fusion
      body_id = getBodyID(dex_number)
      head_id = getHeadID(dex_number, body_id)
      kuraychose = kurayGetCustomDoubleFusion(dex_number, head_id, body_id, usedefault)
      return nil if kuraychose == nil
      return kuraychose
    end
  end
  return nil
end

##### END OF Kuray's Global Functions #####

class Bitmap
  attr_accessor :storedPath

  alias mkxp_draw_text draw_text unless method_defined?(:mkxp_draw_text)

  def draw_text(x, y, width, height, text, align = 0)
    height = text_size(text).height
    mkxp_draw_text(x, y, width, height, text, align)
  end
end

module Graphics
  def self.delta_s
    return self.delta.to_f / 1_000_000
  end
end

def pbSetResizeFactor(factor)
  if !$ResizeInitialized
    Graphics.resize_screen(Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
    $ResizeInitialized = true
  end
  if factor < 0 || factor == 4
    Graphics.fullscreen = true if !Graphics.fullscreen
  else
    Graphics.fullscreen = false if Graphics.fullscreen
    Graphics.scale = (factor + 1) * 0.5
    Graphics.center
  end
end
