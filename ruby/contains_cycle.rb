class LinkedListNode
  attr_accessor :value, :next
  def initialize(value)
    @value = value
    @next  = nil
  end
end

def contains_cycle(ll)
  return false unless ll

  seen = {}
  while (e = ll.next) do 
    return true if seen[e.object_id]
    seen[e.object_id] = 1
  end
  false
end

RSpec.describe "LinkedListCheck" do
  describe "linked list" do
    it "does not contain a cycle when passed nil" do
      expect(contains_cycle(nil)).to be_falsey
    end

    it "does not contain a cycle when passed a single element list" do
      expect(contains_cycle(LinkedListNode.new(1))).to be_falsey
    end

    it "does not contain a cycle when passed a multi element list with no repeats" do
      ll =  LinkedListNode.new(1).next = LinkedListNode.new(2)
      expect(contains_cycle(ll)).to be_falsey
    end

    it "does contain a cycle when an element points to itself" do
      ll =  LinkedListNode.new(1)
      ll.next = ll
      expect(contains_cycle(ll)).to be_truthy
    end
             
    it "does contain a cycle when last element points to first" do
      node1 = LinkedListNode.new(1)
      node2 = LinkedListNode.new(2)
      node1.next = node2
      node2.next = node1
      expect(contains_cycle(node1)).to be_truthy
    end

    it "does contain a cycle when an element points to a previous element" do
      node1 = LinkedListNode.new(1)
      node2 = LinkedListNode.new(2)
      node3 = LinkedListNode.new(3)
      node1.next = node2
      node2.next = node3
      node3.next = node2
      expect(contains_cycle(node1)).to be_truthy
    end
  end
end
