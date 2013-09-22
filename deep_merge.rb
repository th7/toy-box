# merge nested hashes

class Hash
  def deep_merge(other)
    merge(other) do |key, a, b|
      if a.kind_of?(Hash)
        a.merge(b)
      else
        b
      end
    end
  end
end
