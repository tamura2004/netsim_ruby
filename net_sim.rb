# encoding: utf-8

# 各種共通処理
class Node

  # 種類ごとの連番で名前を生成
  attr_reader :name
  def self.name
    @x ||= 0
    "%s%03d" % [super, @x += 1]
  end
  def initialize &block
    @name = self.class.name
    instance_eval &block
  end

  # トレース表示
  def send packet
    puts "#{@name} send #{packet}"
  end
  def recv packet, from:
    puts "#{@name} recv #{packet} from #{from.name}"
  end
  def reject packet
    puts "#{@name} reject #{packet}"
  end
  def do_something packet
    puts "#{@name} do_something #{packet}"
  end
end

# PC
class PC < Node
  def connect other; @other = other; end
  def send packet; super; @other.recv packet,from:self; end
  def recv packet,from:
    super
    if packet[0] == @addr then do_something packet else reject packet end
  end
end

# ハブ
class Hub < Node
  def connect other; @connections=[] if @connections.nil?; @connections << other; end
  def recv packet, from:
    super
    @connections.each do |conn|
      next if conn.equal? from
      conn.recv packet, from:self
    end
  end
end

# とりあえずインスタンスなしのモジュールで実装
module Cable
  def self.connect x,y
    x.connect y
    y.connect x
  end
end

# model

pc1 = PC.new{@addr="A"}
pc2 = PC.new{@addr="B"}
pc3 = PC.new{@addr="C"}
hub1 = Hub.new{}
hub2 = Hub.new{}
hub3 = Hub.new{}

Cable.connect pc1,hub1
Cable.connect pc2,hub2
Cable.connect pc3,hub3
Cable.connect hub1,hub2
Cable.connect hub1,hub3

pc1.send ["B","hello"]
pc1.send ["C","hello"]




