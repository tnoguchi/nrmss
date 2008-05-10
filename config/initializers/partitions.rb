# http://ujihisa.nowa.jp/entry/58b1525627
module Enumerable
  def partitions
    self.inject({}) {|hash, i| (hash[yield(i)] ||= []) << i; hash }.
      map {|key, value| value }
  end
end
